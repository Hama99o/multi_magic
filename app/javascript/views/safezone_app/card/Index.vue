<template>
  <Dashboard>
    <template #container>
      <div class="mb-6 flex flex-wrap items-start justify-start gap-2">
        <h2 class="mb-sm-0 mb-2 text-2xl font-semibold">
          Cards ({{ pagination.total_items || 0 }})
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
          @update:model-value="searchCards"
        />

        <v-btn color="primary" prepend-icon="mdi-plus" @click="newCardRef.dialog = true">
          Add New
        </v-btn>
      </div>

      <!-- Infinite Scroll for Cards -->
      <v-infinite-scroll
        class="overflow-hidden"
        v-if="cards.length"
        height="100%"
        :items="cards"
        :onLoad="fetchMoreData"
      >
        <v-row>
          <template v-for="(card, index) in cards" :key="card.id">
            <v-col cols="12" sm="6" md="4" lg="3">
              <v-card
                variant="outlined"
                class="h-[119px] cursor-pointer hover:border-primary"
                @click="selectCard(card)"
              >
                <v-card-item>
                  <div class="d-flex align-center">
                    <v-avatar v-if="card.link" size="40" rounded="lg" class="mr-4">
                      <v-img
                        :src="`https://www.google.com/s2/favicons?domain=${card.link}&sz=50`"
                        :alt="card.title"
                      ></v-img>
                    </v-avatar>
                    <v-icon v-else icon="mdi mdi-card-outline" size="50"></v-icon>
                    <div class="flex-grow-1">
                      <v-card-title class="pa-0 text-body-1 font-medium">
                        {{ card.title }}
                      </v-card-title>
                      <v-card-subtitle class="pa-0">
                        {{ card.type }}
                      </v-card-subtitle>
                    </div>
                  </div>
                  <div class="mt-2 text-sm">Last updated {{ card.updated_at }}</div>
                </v-card-item>
              </v-card>
            </v-col>
          </template>
        </v-row>
        <template #empty />
      </v-infinite-scroll>
    </template>
  </Dashboard>

  <!-- <ShowAndEdit ref="showAndEditRef" :card="selectedCard" /> -->
  <NewCard ref="newCardRef" />
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { storeToRefs } from 'pinia';
import Dashboard from '@/views/safezone_app/Dashboard.vue';
import NewCard from '@/views/safezone_app/payment_card/New.vue';
import { useCardStore } from '@/stores/safezone_app/card.store';
// import ShowAndEdit from '@/components/safezone_app/card/ShowAndEdit.vue';

const selectedCard = ref(null);
const { cards, pagination, search, page, totalPages } = storeToRefs(useCardStore());
const { fetchCards, fetchMoreCards } = useCardStore();

onMounted(async () => {
  await fetchCards();
});

const newCardRef = ref(null);
const showAndEditRef = ref(false);

const selectCard = (card = {}) => {
  selectedCard.value = { ...card };
  showAndEditRef.value.dialog = true;
};

const searchCards = async () => {
  await fetchCards();
};

// Infinite Scroll - Load More Cards
async function fetchMoreData({ done }) {
  if (page.value < totalPages.value) {
    try {
      page.value += 1;
      const moreCards = await fetchMoreCards();
      if (moreCards.length) {
        cards.value.push(...moreCards);
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
