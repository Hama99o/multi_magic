<template>
  <Dashboard>
    <template #container>
      <div class="d-flex justify-space-between align-center mb-6 flex-wrap">
        <h2 class="mb-sm-0 mb-2 text-2xl font-semibold">Cards</h2>
        <v-btn color="primary" prepend-icon="mdi-plus" @click="showAddModal = true">
          Add New
        </v-btn>
      </div>
      <!-- IDs Section -->
      <v-row>
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
    </template>
  </Dashboard>
</template>

<script setup>
import { ref } from 'vue';
import Dashboard from '@/views/safezone_app/Dashboard.vue';

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

const selectId = (/** @type {any} */ id) => {
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
