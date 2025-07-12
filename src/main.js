import { createApp } from 'vue'
import './assets/styles/main.css'
import App from './App.vue'
import router from './router'

const app = createApp(App)

app.use(router)
app.mount('#app')

// Register service worker for offline capability
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/claude-learn/sw.js')
      .then(registration => {
        console.log('ServiceWorker registration successful')
      })
      .catch(error => {
        console.log('ServiceWorker registration failed:', error)
      })
  })
}