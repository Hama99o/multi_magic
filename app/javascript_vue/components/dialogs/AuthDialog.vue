<template>
  <div>
    <!-- Auth Dialog -->
    <v-dialog v-model="showDialog" max-width="400px" class="rounded-lg">
      <v-card class="bg-gray-900 text-white">
        <div class="absolute top-4 right-4">
          <v-btn icon variant="text" @click="closeDialog">
            <v-icon>mdi-close</v-icon>
          </v-btn>
        </div>

        <v-card-text class="pt-12 px-6">
          <div class="text-center mb-8">
            <v-avatar size="80" class="mb-4 bg-gray-800 p-4">
              <v-icon size="40" color="white">mdi-account-circle</v-icon>
            </v-avatar>
            <h2 class="text-2xl font-bold mb-2">Log in to continue</h2>
            <p class="text-gray-400">
              Join our community to share your thoughts and engage with others
            </p>
          </div>

          <div class="space-y-4">
            <v-btn
              block
              color="primary"
              height="48"
              class="mb-3"
              @click="navigateTo('login')"
            >
              Log in
            </v-btn>
            <v-btn
              block
              variant="outlined"
              height="48"
              class="border-gray-700 hover:bg-gray-800"
              @click="navigateTo('signup')"
            >
              Create account
            </v-btn>
          </div>
        </v-card-text>
      </v-card>
    </v-dialog>

    <!-- Comment Section Wrapper -->
    <div @click="handleCommentAction">
      <slot></slot>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { storeToRefs } from 'pinia'
import { useUserStore } from '@/stores/user.store'

const props = defineProps({
  hashId: { type: String, default: '' }
});

const router = useRouter()
const route = useRoute()
const { currentUser } = storeToRefs(useUserStore())

const showDialog = ref(false)

const closeDialog = () => {
  showDialog.value = false
}

const navigateTo = (routeName) => {
  closeDialog()
  const currentPath = route.fullPath

  if (props.hashId) {
    sessionStorage.setItem('redirectAfterLogin', `${currentPath}${props.hashId}`)
  } else {
    sessionStorage.setItem('redirectAfterLogin', currentPath)
  }
  router.push({ name: routeName })
}

const handleCommentAction = (event) => {
  const isCommentAction = event.target.closest('.reply-btn, .vote-btn, textarea, button')

  if (isCommentAction && !currentUser.value) {
    event.preventDefault()
    event.stopPropagation()
    showDialog.value = true
  }
}

// Watch for changes in currentUser
watch(currentUser, (newUser) => {
  if (newUser) {
    showDialog.value = false
  }
})
</script>

<style scoped>
/* Additional Tailwind utilities */
.v-dialog :deep(.v-overlay__content) {
  @apply shadow-xl;
}

.v-btn {
  @apply font-medium text-base;
}

.v-btn:deep(.v-btn__content) {
  @apply tracking-wide;
}
</style>