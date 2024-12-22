<template>
  <Dashboard>
    <template #container>
      <div class="d-flex justify-space-between align-center mb-6 flex-wrap">
        <h2 class="mb-sm-0 mb-2 text-2xl font-semibold">Payments</h2>
        <v-btn color="primary" prepend-icon="mdi-plus" @click="showAddModal = true">
          Add New
        </v-btn>
      </div>
      <v-row>
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
    </template>
  </Dashboard>
</template>

<script setup>
import { ref } from 'vue';
import Dashboard from '@/views/safezone_app/Dashboard.vue';

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

const selectPayment = (payment) => {
  // Implement payment selection functionality
  console.log('Selected payment:', payment);
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
