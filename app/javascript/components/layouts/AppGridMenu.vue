<template>
  <dropdown
    v-model="menu"
    :offset="8"
    bottom
  >
    <template v-slot:activator="{ props }">
      <v-toolbar class="bg-surface">
        <v-toolbar-items>
          <v-btn
            icon
            v-bind="props"
          >
            <v-icon class="text-primary">mdi-view-grid-outline</v-icon>
          </v-btn>
        </v-toolbar-items>
      </v-toolbar >
    </template>

    <template #dropdown>
      <v-card max-width="400" class="bg-surface p-6 shadow-lg">
        <v-container>
          <v-row class="flex flex-wrap justify-center">
            <v-col
              v-for="app in menuItems"
              :key="app.title"
              cols="6"
              class="group flex items-center hover:bg-background justify-center cursor-pointer p-4 transition-transform duration-200 transform hover:scale-105 hover:bg-info"
              @click="goToApp(app.routeName, app.query)"
            >
              <div class="flex flex-col items-center text-center gap-3">
                <v-icon :icon="app.icon" class="text-5xl group-hover:text-indigo-500 transition-colors duration-200" :alt="app.title"/>
                <div class="text-center text-lg text-nowrap font-semibold group-hover:text-indigo-500 transition-colors duration-200">
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

const menu = ref(false)
const router = useRouter()

const props = defineProps({
  isSuperAdmin: { type: Boolean, required: true },
  currentUser: { type: Object },
});

const apps = ref([
  { title: 'Users', routeName: 'users', icon: 'mdi-account-group', appName: 'Users', query: {} },
  { title: 'My Notes', routeName: 'notes', icon: 'mdi mdi-note', appName: 'NoteApp', query: { page: 'all_notes' } },
  { title: 'My Finance', routeName: 'expenses', icon: 'mdi mdi-cash-multiple', appName: 'MyFinanceApp', query: {} },
  { title: 'My Contacts', routeName: 'contacts', icon: 'mdi mdi-account-box', appName: 'ContactApp', query: {} },
  { title: 'My Blog', routeName: 'articles', icon: 'mdi mdi-school', appName: 'BlogApp', query: {} }
])

const goToApp = (routeName, query) => {
  router.push({
    name: routeName,
    query: query
  })
  menu.value = false
}

const menuItems = computed(() => {
  return apps.value.filter((item) => props.currentUser?.applications?.includes(item.appName))
});
</script>


