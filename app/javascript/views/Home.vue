<template>
  <v-app>
    <!-- Left Sidebar (hidden on mobile) -->
    <v-navigation-drawer v-model="drawer" class="bg-white">
      <v-list class="pa-4">
        <div class="mb-6 flex items-center gap-2">
          <v-avatar color="primary" size="32" class="rounded-lg">
            <v-icon icon="mdi-key-variant" color="white"></v-icon>
          </v-avatar>
          <span class="text-lg font-semibold">Safezone</span>
        </div>

        <v-text-field
          prepend-inner-icon="mdi-magnify"
          placeholder="Search"
          variant="outlined"
          density="compact"
          hide-details
          class="mb-4"
        ></v-text-field>

        <v-list-item
          v-for="item in menuItems"
          :key="item.title"
          :prepend-icon="item.icon"
          :title="item.title"
          :active="activeSection === item.value"
          rounded="lg"
          class="mb-1"
          @click="activeSection = item.value"
        ></v-list-item>
      </v-list>
    </v-navigation-drawer>

    <!-- Main Content -->
    <v-main class="bg-gray-50">
      <v-app-bar :elevation="0" color="white" class="d-flex d-md-none">
        <v-app-bar-nav-icon @click="drawer = !drawer"></v-app-bar-nav-icon>
        <v-app-bar-title>Safezone</v-app-bar-title>
      </v-app-bar>

      <v-container class="py-md-8 py-4">
        <div class="d-flex justify-space-between align-center mb-6 flex-wrap">
          <h2 class="mb-sm-0 mb-2 text-2xl font-semibold">{{ activeSection }}</h2>
          <v-btn color="primary" prepend-icon="mdi-plus" @click="showAddModal = true">
            Add New
          </v-btn>
        </div>

        <!-- Password Section -->
        <PasswordIndex />

        <!-- Secure Notes Section -->
        <SecureNoteIndex />

        <!-- Payments Section -->
        <PaymentsIndex />

        <!-- IDs Section -->
        <CardIndex />

        <!-- Empty state for Sharing Center, Support, and Settings -->
        <v-row v-if="['Sharing Center', 'Support', 'Settings'].includes(activeSection)">
          <v-col cols="12">
            <v-card class="pa-8 text-center">
              <v-icon icon="mdi-folder-open" size="64" color="gray"></v-icon>
              <h3 class="text-h5 mt-4">No content available</h3>
              <p class="text-body-1 mt-2 text-gray-600">This section is currently empty.</p>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </v-main>
  </v-app>
</template>

<script setup>
import { ref } from 'vue';
import { useDisplay } from 'vuetify';
import PasswordIndex from '@/views/safezone_app/password/Index.vue';
import SecureNoteIndex from '@/views/safezone_app/secure_note/Index.vue';
import PaymentsIndex from '@/views/safezone_app/payments/Index.vue';
import CardIndex from '@/views/safezone_app/card/Index.vue';

const display = useDisplay();
const drawer = ref(display.mdAndUp.value);
const activeSection = ref('Passwords');

const menuItems = [
  { title: 'Passwords', icon: 'mdi-lock', value: 'Passwords' },
  { title: 'Secure Notes', icon: 'mdi-text-box', value: 'Secure Notes' },
  { title: 'Payments', icon: 'mdi-credit-card', value: 'Payments' },
  { title: 'IDs', icon: 'mdi-card-account-details', value: 'IDs' },
  { title: 'Sharing Center', icon: 'mdi-share-variant', value: 'Sharing Center' },
  { title: 'Support', icon: 'mdi-help-circle', value: 'Support' },
  { title: 'Settings', icon: 'mdi-cog', value: 'Settings' },
];
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
