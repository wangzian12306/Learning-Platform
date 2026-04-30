import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useUserStore = defineStore('user', () => {
  const token = ref(localStorage.getItem('token') || '')
  const userInfo = ref(null)

  function setToken(val) {
    token.value = val
    localStorage.setItem('token', val)
  }

  function setUserInfo(info) {
    userInfo.value = info
  }

  function logout() {
    token.value = ''
    userInfo.value = null
    localStorage.removeItem('token')
  }

  const isLoggedIn = () => !!token.value

  return { token, userInfo, setToken, setUserInfo, logout, isLoggedIn }
})
