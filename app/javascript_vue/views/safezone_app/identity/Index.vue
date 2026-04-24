<template>
  <dashboard>
    <template #container>
      <div class="mb-6 flex flex-wrap items-start justify-start gap-2">
        <h2 class="mb-sm-0 mb-2 text-2xl font-semibold">
          Identities ({{ pagination.total_items || 0 }})
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
          @update:model-value="handleSearch"
        />

        <v-btn color="primary" prepend-icon="mdi-plus" @click="openCreateDialog"> Add New </v-btn>
      </div>
      <!-- Infinite Scroll for identities -->
      <v-infinite-scroll
        class="overflow-hidden"
        v-if="identities.length"
        height="100%"
        :items="identities"
        :onLoad="fetchMoreData"
      >
        <v-row>
          <template v-for="(card, index) in identities" :key="card.id">
            <v-col cols="12" sm="6" md="4" lg="3">
              <v-card
                variant="outlined"
                class="h-[119px] cursor-pointer hover:border-primary"
                @click="selectPayment(card)"
              >
                <v-card-item>
                  <div class="d-flex align-center">
                    <v-avatar
                      size="40"
                      rounded="lg"
                      :color="getIdentityTypeColor(card.type)"
                      class="mr-4"
                    >
                      <v-icon :icon="getIdentityTypeIcon(card.type)" color="white"></v-icon>
                    </v-avatar>
                    <div class="flex-grow-1">
                      <v-card-title class="pa-0 text-body-1 font-medium">
                        {{ card.documentNumber }}
                      </v-card-title>
                      <v-card-subtitle class="pa-0 text-gray-500">
                        {{ getIdentityTypeText(card.type) }}
                      </v-card-subtitle>
                    </div>
                  </div>
                  <div class="mt-2 text-sm text-gray-400">Expires {{ card.expiresAt }}</div>
                </v-card-item>
              </v-card>
            </v-col>
          </template>
        </v-row>
        <template #empty />
      </v-infinite-scroll>
    </template>
  </dashboard>

  <ShowAndEdit ref="showAndEditRef" :identity="selectedPayment" />
  <NewCard ref="newCardRef" />
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { storeToRefs } from 'pinia';
import { useIdentityStore } from '@/stores/safezone_app/identity.store';
import Dashboard from '@/views/safezone_app/Dashboard.vue';
import NewCard from '@/views/safezone_app/identity/New.vue';
import ShowAndEdit from '@/components/safezone_app/identity/CardShowAndEdit.vue';

// Initialize store
const { identities, pagination, search, page, totalPages } = storeToRefs(useIdentityStore());
const { fetchIdentities, fetchMoreIdentities } = useIdentityStore();

const newCardRef = ref(null);
const selectedPayment = ref(null);
const showAndEditRef = ref(false);

// Fetch identities on component mount
onMounted(async () => {
  await fetchIdentities();
});

const selectPayment = (payment = {}) => {
  search.value = '';
  page.value = 1;
  selectedPayment.value = { ...payment };
  showAndEditRef.value.dialog = true;
};

// Methods
const handleSearch = async () => {
  page.value = 1;
  await fetchIdentities();
};

const openCreateDialog = () => {
  newCardRef.value.dialog = true;
};

// Infinite Scroll - Load More Payments
async function fetchMoreData({ done }) {
  if (page.value < totalPages.value) {
    try {
      page.value += 1;
      const moreIdentities = await fetchMoreIdentities();
      if (moreIdentities?.length) {
        identities.value.push(...moreIdentities);
      }
      done('ok');
    } catch (error) {
      done('error');
    }
  } else {
    done('empty');
  }
}

const getIdentityTypeText = (type) => {
  switch (type) {
    case 'SafezoneApp::Identities::Passport':
      return 'Passport';
    case 'SafezoneApp::Identities::IdCard':
      return 'ID Card';
    case 'SafezoneApp::Identities::DrivingLicense':
      return 'Driving License';
    default:
      return type;
  }
};

const getIdentityTypeIcon = (type) => {
  switch (type) {
    case 'SafezoneApp::Identities::Passport':
      return 'mdi-passport';
    case 'SafezoneApp::Identities::IdCard':
      return 'mdi-card-account-details';
    case 'SafezoneApp::Identities::DrivingLicense':
      return 'mdi-car';
    default:
      return 'mdi-file-document';
  }
};

const getIdentityTypeColor = (type) => {
  switch (type) {
    case 'SafezoneApp::Identities::Passport':
      return 'primary';
    case 'SafezoneApp::Identities::IdCard':
      return 'success';
    case 'SafezoneApp::Identities::DrivingLicense':
      return 'warning';
    default:
      return 'info';
  }
};
</script>

<style></style>
