<template>
  <v-app>
    <!-- Left Sidebar (hidden on mobile) -->
    <v-navigation-drawer v-model="drawer" class="bg-secondary">
      <v-list class="pa-4">
        <div class="items-between flex justify-between">
          <div class="flex items-center justify-center gap-2">
            <v-avatar color="primary" size="32" class="rounded-lg">
              <v-icon icon="mdi-key-variant" color="white"></v-icon>
            </v-avatar>
            <span class="text-lg font-semibold">Safezone</span>
          </div>
          <v-btn
            class="items-center"
            variant="text"
            :icon="drawer ? 'mdi mdi-menu-open' : 'mdi mdi-backburger'"
            @click="drawer = !drawer"
          ></v-btn>
        </div>

        <v-list-item
          v-for="item in menuItems"
          :key="item.title"
          :prepend-icon="item.icon"
          :title="item.title"
          :active="item?.routeName === route.name"
          rounded="lg"
          class="my-4"
          :class="item?.routeName === route.name ? 'bg-info' : ''"
          @click="goToApp(item?.routeName, item.value)"
        ></v-list-item>
      </v-list>
    </v-navigation-drawer>

    <!-- Main Content -->
    <v-main class="bg-background">
      <v-app-bar v-if="isMobile || !drawer" :elevation="0" color="secondary" class="d-flex">
        <v-app-bar-nav-icon
          :icon="drawer ? 'mdi mdi-menu-open' : 'mdi mdi-menu-open'"
          @click="drawer = !drawer"
        ></v-app-bar-nav-icon>
        <v-app-bar-title>Safezone</v-app-bar-title>
      </v-app-bar>

      <v-container>
        <slot name="container" />
      </v-container>
    </v-main>
  </v-app>
</template>

<script setup>
import { ref } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { storeToRefs } from 'pinia';
import { useMobileStore } from '@/stores/mobile';
const { isMobile } = storeToRefs(useMobileStore());
const router = useRouter();
const route = useRoute();
const drawer = ref(!isMobile.value);
const activeSection = ref('Passwords');

const menuItems = [
  { title: 'Passwords', icon: 'mdi-lock', value: 'Passwords', routeName: 'safezone_app_passwords' },
  {
    title: 'Payments',
    icon: 'mdi-credit-card',
    value: 'Payments',
    routeName: 'safezone_app_payment_cards',
  },
  {
    title: 'Secure Notes',
    icon: 'mdi-text-box',
    value: 'Secure Notes',
    routeName: 'safezone_app_secure_notes',
  },
  {
    title: 'Cards',
    icon: 'mdi-card-account-details',
    value: 'Cards',
    routeName: 'safezone_app_cards',
  },
  { title: 'Sharing Center', icon: 'mdi-share-variant', value: 'Sharing Center' },
  { title: 'Support', icon: 'mdi-help-circle', value: 'Support' },
  { title: 'Settings', icon: 'mdi-cog', value: 'Settings' },
];

const goToApp = (/** @type {any} */ routeName, /** @type {string} */ value) => {
  activeSection.value = value;
  router.push({
    name: routeName,
  });
};
</script>

<style>
.v-list-item--active {
  background-color: rgb(var(--v-theme-primary));
  color: white;
}

.v-list-item--active .v-list-item__prepend {
  color: white;
}
</style>
