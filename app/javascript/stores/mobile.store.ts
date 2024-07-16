import { defineStore } from "pinia";
import { onMounted, onUnmounted, ref } from "vue";

export const useMobileStore = defineStore("mobile", () => {
  const isMobile = ref(window.innerWidth < 640)
  const isMdScreen = ref(window.innerWidth > 768)
  const isLgScreen = ref(window.innerWidth > 1024)
  const isXlScreen = ref(window.innerWidth > 1280)
  const isLargeScreen = ref(window.innerWidth > 1400)

  const handleWindowResize = (e) => {
    isMobile.value = e.target.innerWidth < 640
    isMdScreen.value = e.target.innerWidth > 768
    isLgScreen.value = e.target.innerWidth > 1024
    isXlScreen.value = e.target.innerWidth > 1280
    isLargeScreen.value = e.target.innerWidth > 1400
  }

  onMounted(() => {
    window.addEventListener("resize", handleWindowResize)
  })

  onUnmounted(() => {
    window.removeEventListener("resize", handleWindowResize)
  })

  return { isMobile, isMdScreen, isLgScreen, isXlScreen, isLargeScreen }
});
