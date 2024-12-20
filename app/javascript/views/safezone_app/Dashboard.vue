<template>
  <v-app>
    <!-- Left Sidebar (hidden on mobile) -->
    <v-navigation-drawer
      v-model="drawer"
      :permanent="$vuetify.display.mdAndUp"
      :temporary="$vuetify.display.smAndDown"
      class="bg-white"
    >
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

        <!-- Passwords Section -->
        <v-row v-if="activeSection === 'Passwords'">
          <v-col v-for="password in passwords" :key="password.id" cols="12" sm="6" md="4" lg="3">
            <v-card
              variant="outlined"
              class="cursor-pointer hover:border-primary"
              @click="selectPassword(password)"
            >
              <v-card-item>
                <div class="d-flex align-center">
                  <v-avatar size="40" rounded="lg" class="mr-4 bg-gray-100">
                    <v-img
                      :src="`https://www.google.com/s2/favicons?domain=${password.website}&sz=64`"
                      :alt="password.title"
                    ></v-img>
                  </v-avatar>
                  <div class="flex-grow-1">
                    <v-card-title class="pa-0 text-body-1 font-medium">
                      {{ password.title }}
                    </v-card-title>
                    <v-card-subtitle class="pa-0 text-gray-500">
                      {{ password.username }}
                    </v-card-subtitle>
                  </div>
                </div>
                <div class="mt-2 text-sm text-gray-400">Last used {{ password.lastUsed }}</div>
              </v-card-item>
            </v-card>
          </v-col>
        </v-row>

        <!-- Secure Notes Section -->
        <v-row v-if="activeSection === 'Secure Notes'">
          <v-col v-for="note in secureNotes" :key="note.id" cols="12" sm="6" md="4" lg="3">
            <v-card
              variant="outlined"
              class="cursor-pointer hover:border-primary"
              @click="selectNote(note)"
            >
              <v-card-item>
                <div class="d-flex align-center">
                  <v-avatar size="40" rounded="lg" color="primary" class="mr-4">
                    <v-icon icon="mdi-note-text" color="white"></v-icon>
                  </v-avatar>
                  <div class="flex-grow-1">
                    <v-card-title class="pa-0 text-body-1 font-medium">
                      {{ note.title }}
                    </v-card-title>
                    <v-card-subtitle class="pa-0 text-gray-500">
                      {{ note.content.substring(0, 30) }}...
                    </v-card-subtitle>
                  </div>
                </div>
                <div class="mt-2 text-sm text-gray-400">Last edited {{ note.lastEdited }}</div>
              </v-card-item>
            </v-card>
          </v-col>
        </v-row>

        <!-- Payments Section -->
        <v-row v-if="activeSection === 'Payments'">
          <v-col v-for="payment in payments" :key="payment.id" cols="12" sm="6" md="4" lg="3">
            <v-card
              variant="outlined"
              class="cursor-pointer hover:border-primary"
              @click="selectPayment(payment)"
            >
              <v-card-item>
                <div class="d-flex align-center">
                  <v-avatar
                    size="40"
                    rounded="lg"
                    :color="payment.type === 'credit' ? 'error' : 'success'"
                    class="mr-4"
                  >
                    <v-icon
                      :icon="payment.type === 'credit' ? 'mdi-credit-card' : 'mdi-bank'"
                      color="white"
                    ></v-icon>
                  </v-avatar>
                  <div class="flex-grow-1">
                    <v-card-title class="pa-0 text-body-1 font-medium">
                      {{ payment.name }}
                    </v-card-title>
                    <v-card-subtitle class="pa-0 text-gray-500">
                      {{
                        payment.type === 'credit'
                          ? '****' + payment.lastFour
                          : payment.accountNumber
                      }}
                    </v-card-subtitle>
                  </div>
                </div>
                <div class="mt-2 text-sm text-gray-400">Expires {{ payment.expiryDate }}</div>
              </v-card-item>
            </v-card>
          </v-col>
        </v-row>

        <!-- IDs Section -->
        <v-row v-if="activeSection === 'IDs'">
          <v-col v-for="id in ids" :key="id.id" cols="12" sm="6" md="4" lg="3">
            <v-card
              variant="outlined"
              class="cursor-pointer hover:border-primary"
              @click="selectId(id)"
            >
              <v-card-item>
                <div class="d-flex align-center">
                  <v-avatar size="40" rounded="lg" color="warning" class="mr-4">
                    <v-icon icon="mdi-card-account-details" color="white"></v-icon>
                  </v-avatar>
                  <div class="flex-grow-1">
                    <v-card-title class="pa-0 text-body-1 font-medium">
                      {{ id.type }}
                    </v-card-title>
                    <v-card-subtitle class="pa-0 text-gray-500">
                      {{ id.name }}
                    </v-card-subtitle>
                  </div>
                </div>
                <div class="mt-2 text-sm text-gray-400">Expires {{ id.expiryDate }}</div>
              </v-card-item>
            </v-card>
          </v-col>
        </v-row>

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

    <!-- Password Detail Dialog -->
    <v-dialog v-model="showPasswordDetail" max-width="500" fullscreen-sm>
      <v-card v-if="selectedPassword">
        <v-toolbar v-if="$vuetify.display.smAndDown" color="primary" prominent>
          <v-btn icon @click="showPasswordDetail = false">
            <v-icon>mdi-close</v-icon>
          </v-btn>
          <v-toolbar-title>Password Details</v-toolbar-title>
        </v-toolbar>

        <v-card-item>
          <div class="d-flex align-center gap-4">
            <v-avatar size="48" rounded="lg" class="bg-gray-100">
              <v-img
                :src="`https://www.google.com/s2/favicons?domain=${selectedPassword.website}&sz=64`"
                :alt="selectedPassword.title"
              ></v-img>
            </v-avatar>
            <div>
              <v-card-title class="pa-0 text-xl font-semibold">
                {{ selectedPassword.title }}
              </v-card-title>
              <v-card-subtitle class="pa-0 text-gray-500">
                {{ selectedPassword.website }}
              </v-card-subtitle>
            </div>
          </div>
        </v-card-item>

        <v-card-text>
          <v-form class="space-y-4">
            <v-text-field
              v-model="selectedPassword.username"
              label="Username"
              readonly
              append-inner-icon="mdi-content-copy"
              variant="outlined"
              density="comfortable"
              @click:append-inner="copyToClipboard(selectedPassword.username)"
            ></v-text-field>

            <v-text-field
              v-model="selectedPassword.password"
              label="Password"
              :type="showPassword ? 'text' : 'password'"
              readonly
              :append-inner-icon="showPassword ? 'mdi-eye-off' : 'mdi-eye'"
              variant="outlined"
              density="comfortable"
              @click:append-inner="showPassword = !showPassword"
            >
              <template #append>
                <v-icon
                  icon="mdi-content-copy"
                  class="ml-2"
                  @click="copyToClipboard(selectedPassword.password)"
                ></v-icon>
              </template>
            </v-text-field>

            <div>
              <div class="d-flex justify-space-between mb-1 text-sm">
                <span class="text-gray-600">Password strength</span>
                <span class="text-success">Strong</span>
              </div>
              <v-progress-linear
                model-value="85"
                color="success"
                height="8"
                rounded
              ></v-progress-linear>
            </div>

            <v-textarea
              v-model="selectedPassword.notes"
              label="Notes"
              readonly
              variant="outlined"
              rows="3"
            ></v-textarea>
          </v-form>
        </v-card-text>

        <v-card-actions class="pa-6">
          <v-btn
            color="error"
            variant="outlined"
            block
            :class="{ 'mb-2': $vuetify.display.smAndDown }"
            @click="deletePassword"
          >
            Delete
          </v-btn>
          <v-spacer v-if="$vuetify.display.mdAndUp"></v-spacer>
          <v-btn
            color="primary"
            block
            :class="{ 'mt-2': $vuetify.display.smAndDown }"
            @click="editPassword"
          >
            Edit
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-app>
</template>

<script setup>
import { ref } from 'vue';
import { useDisplay } from 'vuetify';

const display = useDisplay();
const drawer = ref(display.mdAndUp.value);
const showPasswordDetail = ref(false);
const showPassword = ref(false);
const selectedPassword = ref(null);
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

const passwords = ref([
  {
    id: 1,
    title: 'Airtable',
    username: 'user@example.com',
    password: 'securePassword123!',
    website: 'airtable.com',
    lastUsed: '2 days ago',
    notes: 'Work account for project management',
  },
  {
    id: 2,
    title: 'Pinterest',
    username: 'pinterestuser',
    password: 'pinSecure456!',
    website: 'pinterest.com',
    lastUsed: '5 days ago',
    notes: 'Personal account',
  },
  {
    id: 3,
    title: 'Google Calendar',
    username: 'user@gmail.com',
    password: 'gCal789Secure!',
    website: 'calendar.google.com',
    lastUsed: '1 week ago',
    notes: 'Main calendar account',
  },
]);

const secureNotes = ref([
  {
    id: 1,
    title: 'Work Project Ideas',
    content: 'Brainstorming ideas for the new marketing campaign...',
    lastEdited: '1 day ago',
  },
  {
    id: 2,
    title: 'Personal Goals',
    content: '1. Learn a new language\n2. Run a marathon\n3. Start a side business',
    lastEdited: '1 week ago',
  },
  {
    id: 3,
    title: 'Gift Ideas',
    content: 'Mom: Cookbook\nDad: Golf clubs\nSister: Spa day',
    lastEdited: '2 weeks ago',
  },
]);

const payments = ref([
  {
    id: 1,
    name: 'Main Credit Card',
    type: 'credit',
    lastFour: '1234',
    expiryDate: '12/2025',
  },
  {
    id: 2,
    name: 'Savings Account',
    type: 'bank',
    accountNumber: '*****6789',
    expiryDate: 'N/A',
  },
  {
    id: 3,
    name: 'Business Credit Card',
    type: 'credit',
    lastFour: '5678',
    expiryDate: '03/2024',
  },
]);

const ids = ref([
  {
    id: 1,
    type: "Driver's License",
    name: 'John Doe',
    number: 'DL1234567',
    expiryDate: '05/2026',
  },
  {
    id: 2,
    type: 'Passport',
    name: 'John Doe',
    number: 'PA9876543',
    expiryDate: '10/2028',
  },
  {
    id: 3,
    type: 'Student ID',
    name: 'John Doe',
    number: 'ST567890',
    expiryDate: '09/2023',
  },
]);

const selectPassword = (password) => {
  selectedPassword.value = password;
  showPasswordDetail.value = true;
};

const copyToClipboard = async (text) => {
  try {
    await navigator.clipboard.writeText(text);
    // Add Vuetify snackbar notification here
  } catch (err) {
    console.error('Failed to copy text: ', err);
  }
};

const editPassword = () => {
  // Implement edit functionality
  console.log('Edit password:', selectedPassword.value);
};

const deletePassword = () => {
  // Implement delete functionality
  console.log('Delete password:', selectedPassword.value);
  showPasswordDetail.value = false;
};

const selectNote = (note) => {
  // Implement note selection functionality
  console.log('Selected note:', note);
};

const selectPayment = (payment) => {
  // Implement payment selection functionality
  console.log('Selected payment:', payment);
};

const selectId = (id) => {
  // Implement ID selection functionality
  console.log('Selected ID:', id);
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
