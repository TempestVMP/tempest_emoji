import { createApp, ref, computed, onMounted } from 'vue'

const app = createApp({
    setup() {
        const resource = ref('localhost')
        const emojiData = ref({})
        const selectedType = ref('default')
        const toggleInput = ref(false)
        const emojiMenu = ref(false)
        const newEmojiUrl = ref('')
        const newEmoteInput = ref(false)
        const emojiHTML = ref('')

        const isDebugBrowser = computed(() => !window.invokeNative)
        function drawEmoji(emoji) {
            for (const type in emoji) {
                emojiData.value[type] = emoji[type]
            }
            emojiData.value.user = JSON.parse(localStorage.getItem('emojiStorage')) || []
        }

        const selectCategory = (category) => {
            selectedType.value = category
        }

        const addingEmoji = () => {
            newEmojiUrl.value = ''
            newEmoteInput.value = true
        }

        function addMyEmoji() {
            const index = Object.keys(emojiData.value.user).length
            emojiData.value.user[index] = newEmojiUrl.value
            localStorage.setItem('emojiStorage', JSON.stringify(emojiData.value.user))
            newEmojiUrl.value = ''
            newEmoteInput.value = false
        }

        function removeMyEmoji(index) {
            emojiData.value.user.splice(index, 1)
            localStorage.setItem('emojiStorage', JSON.stringify(emojiData.value.user))
        }

        const selectEmoji = (index) => {
            if (isDebugBrowser.value) {
                console.log(JSON.stringify(selectedType.value), emojiData.value[selectedType.value][index])
                return
            }
            index = emojiData.value[selectedType.value][index]
            proxyCall('selectedEmoji', {link: index})
        }
        const proxyCall = async (method, params = {}) => {
            const response = await fetch(`https://${resource.value}/${method}`, {
                method: 'post',
                body: JSON.stringify(params),
            }).catch(console.error)
            const data = await response.json().catch(console.error)
            return data
        }
        const exit = () => {
            if (isDebugBrowser.value) {
                newEmoteInput.value = false
                toggleInput.value = false
                emojiMenu.value = false
                return
            }
            proxyCall('exit').then(() => {
                newEmoteInput.value = false
                toggleInput.value = false
                emojiMenu.value = false
            })
        }

        onMounted(async () => {
            if (isDebugBrowser.value) {
                const item = cfg.debugData
                drawEmoji(item)
                emojiMenu.value = true
            } else {
                resource.value = GetParentResourceName()
                drawEmoji(await proxyCall('nuiReady'))
            }

            window.addEventListener('message', (event) => {
                const evd = event.data
                if (evd.action === 'draw') {
                    emojiHTML.value = evd.html
                } else
                if (evd.action === 'uiState') {
                    emojiMenu.value = evd.enable
                }
            })

            window.addEventListener('keyup', (ev) => {
                if (ev.key === 'Escape') {
                    exit()
                }
            })
        })

        return {
            emojiData,
            selectedType,
            emojiMenu,
            newEmojiUrl,
            newEmoteInput,
            emojiHTML,
            isDebugBrowser,
            selectCategory,
            selectEmoji,
            addMyEmoji,
            removeMyEmoji,
            addingEmoji,
        }
    },
})
app.mount('#app')
