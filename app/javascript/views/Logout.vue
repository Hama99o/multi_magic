

<template>
  <!-- Empty template -->
</template>

<script setup lang="ts">
import { useAuthStore } from '@/stores/auth.store';
import { onMounted } from 'vue';
import { useRoute, useRouter } from "vue-router";

const router = useRouter();
const { logout } = useAuthStore();

onMounted(() => {
  logout();
  // Redirect to another route after logout
  // router.push({ name: '/' }); // Change 'index' to the name of the route you want to redirect to
});
</script>
