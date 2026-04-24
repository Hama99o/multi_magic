<template>
  <Dashboard>
    <template #container>
      <div class="mb-6 flex flex-wrap items-start justify-start gap-2">
        <h2 class="mb-sm-0 mb-2 text-2xl font-semibold">
          Payments ({{ pagination.total_items || 0 }})
        </h2>

        <!-- Search Input -->
        <v-text-field
          v-model="search"
          class="mx-2 w-fit rounded-lg"
          variant="outlined"
          density="compact"
          hide-details
          clearable
          prepend-inner-icon="mdi-magnify"
          placeholder="Search"
          @update:model-value="searchPayments"
        />

        <v-btn color="primary" prepend-icon="mdi-plus" @click="newPaymentRef.dialog = true">
          Add New
        </v-btn>
      </div>

      <!-- Infinite Scroll for Payments -->
      <v-infinite-scroll
        v-if="paymentCards?.length"
        class="overflow-hidden"
        height="100%"
        :items="paymentCards"
        :onLoad="fetchMoreData"
      >
        <v-row>
          <template v-for="(payment, index) in paymentCards" :key="payment.id">
            <v-col cols="12" sm="6" md="4" lg="3">
              <v-card
                variant="outlined"
                class="h-[119px] cursor-pointer hover:border-primary"
                @click="selectPayment(payment)"
              >
                <v-card-item>
                  <div class="d-flex align-center">
                    <v-avatar
                      size="40"
                      rounded="lg"
                      :color="payment.cardType === 'credit_card' ? 'error' : 'success'"
                      class="mr-4"
                    >
                      <v-icon
                        :icon="payment.cardType === 'credit_card' ? 'mdi-credit-card' : 'mdi-bank'"
                        color="white"
                      ></v-icon>
                    </v-avatar>
                    <div class="flex-grow-1">
                      <v-card-title class="pa-0 text-body-1 font-medium">
                        {{ payment.name }}
                      </v-card-title>
                      <v-card-subtitle class="pa-0 text-gray-500">
                        {{ payment.cardNumber }}
                      </v-card-subtitle>
                    </div>
                  </div>
                  <div class="mt-2 text-sm text-gray-400">Expires {{ payment.expiryDate }}</div>
                </v-card-item>
              </v-card>
            </v-col>
          </template>
        </v-row>
        <template #empty />
      </v-infinite-scroll>
    </template>
  </Dashboard>
  <ShowAndEdit ref="showAndEditRef" :card="selectedPayment" />
  <NewPayment ref="newPaymentRef" />
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { storeToRefs } from 'pinia';
import Dashboard from '@/views/safezone_app/Dashboard.vue';
import NewPayment from '@/views/safezone_app/payment_card/New.vue';
import { usePaymentCardStore } from '@/stores/safezone_app/payment_card.store';
import ShowAndEdit from '@/components/safezone_app/payment_card/CardShowAndEdit.vue';

const selectedPayment = ref(null);
const { paymentCards, pagination, search, page, totalPages } = storeToRefs(usePaymentCardStore());
const { fetchPaymentCards, fetchMorePaymentCards } = usePaymentCardStore();

onMounted(async () => {
  search.value = '';
  page.value = 1;
  await fetchPaymentCards();
});

const newPaymentRef = ref(null);
const showAndEditRef = ref(false);

const selectPayment = (payment = {}) => {
  selectedPayment.value = { ...payment };
  showAndEditRef.value.dialog = true;
};

const searchPayments = async () => {
  await fetchPaymentCards();
};

// Infinite Scroll - Load More Payments
async function fetchMoreData({ done }) {
  if (page.value < totalPages.value) {
    try {
      page.value += 1;
      const morePayments = await fetchMorePaymentCards();
      if (morePayments?.length) {
        paymentCards.value.push(...morePayments);
      }
      done('ok');
    } catch (error) {
      done('error');
    }
  } else {
    done('empty');
  }
}
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
