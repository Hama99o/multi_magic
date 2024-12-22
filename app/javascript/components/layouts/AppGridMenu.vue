<template>
  <dropdown v-model="menu" :offset="8" bottom>
    <template #activator="{ props }">
      <v-toolbar class="bg-surface">
        <v-toolbar-items>
          <v-btn icon v-bind="props">
            <v-icon class="text-primary">mdi-view-grid-outline</v-icon>
          </v-btn>
        </v-toolbar-items>
      </v-toolbar>
    </template>

    <template #dropdown>
      <v-card max-width="400" class="bg-surface p-6 shadow-lg">
        <v-container>
          <v-row class="flex flex-wrap justify-center">
            <v-col
              v-for="app in menuItems"
              :key="app.title"
              cols="6"
              class="group flex transform cursor-pointer items-center justify-center p-4 transition-transform duration-200 hover:scale-105 hover:bg-background hover:bg-info"
              @click="goToApp(app.routeName, app.query)"
            >
              <div class="flex flex-col items-center gap-3 text-center">
                <v-icon
                  :icon="app.icon"
                  class="text-5xl transition-colors duration-200 group-hover:text-indigo-500"
                  :alt="app.title"
                />
                <div
                  class="text-nowrap text-center text-lg font-semibold transition-colors duration-200 group-hover:text-indigo-500"
                >
                  {{ app.title }}
                </div>
              </div>
            </v-col>
          </v-row>
        </v-container>
      </v-card>
    </template>
  </dropdown>
</template>

<script setup>
import { ref, computed } from 'vue';
import { useRouter } from 'vue-router';
import Dropdown from '@/components/button/Dropdown.vue';

const menu = ref(false);
const router = useRouter();

const props = defineProps({
  isSuperAdmin: { type: Boolean, required: true },
  currentUser: { type: Object },
});

const apps = ref([
  {
    title: 'Safezone',
    routeName: 'safezone_app_passwords',
    icon: 'mdi mdi-note',
    appName: 'SafezoneApp',
    query: {},
  },
  {
    title: 'My Notes',
    routeName: 'notes',
    icon: 'mdi mdi-note',
    appName: 'NoteApp',
    query: { page: 'all_notes' },
  },
  {
    title: 'My Finance',
    routeName: 'expenses',
    icon: 'mdi mdi-cash-multiple',
    appName: 'MyFinanceApp',
    query: {},
  },
  {
    title: 'My Contacts',
    routeName: 'contacts',
    icon: 'mdi mdi-account-box',
    appName: 'ContactApp',
    query: {},
  },
  {
    title: 'My Blog',
    routeName: 'articles',
    icon: 'mdi mdi-school',
    appName: 'BlogApp',
    query: {},
  },
  { title: 'Users', routeName: 'users', icon: 'mdi-account-group', appName: 'Users', query: {} },
]);

const goToApp = (routeName, query) => {
  router.push({
    name: routeName,
    query: query,
  });
  menu.value = false;
};

const menuItems = computed(() => {
  return apps.value.filter((item) => props.currentUser?.applications?.includes(item.appName));
});
</script>
