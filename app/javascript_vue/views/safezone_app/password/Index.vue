<template>
  <Dashboard>
    <template #container>
      <div class="mb-6 flex flex-wrap items-start justify-start gap-2">
        <h2 class="mb-sm-0 mb-2 text-2xl font-semibold">
          Passwords ({{ pagination.total_items || 0 }})
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
          @update:model-value="searchPasswords"
        />

        <v-btn color="primary" prepend-icon="mdi-plus" @click="newPasswordRef.dialog = true">
          Add New
        </v-btn>
      </div>

      <!-- Infinite Scroll for Articles -->
      <v-infinite-scroll
        v-if="passwords.length"
        class="overflow-hidden"
        height="100%"
        :items="passwords"
        :onLoad="fetchMoreData"
      >
        <v-row>
          <template v-for="(password, index) in passwords" :key="password">
            <v-col cols="12" sm="6" md="4" lg="3">
              <v-card
                variant="outlined"
                class="h-[119px] cursor-pointer hover:border-primary"
                @click="selectPassword(password)"
              >
                <v-card-item>
                  <div class="d-flex align-center">
                    <v-avatar v-if="password.link" size="40" rounded="lg" class="mr-4">
                      <v-img
                        :src="`https://www.google.com/s2/favicons?domain=${password.link}&sz=50`"
                        :alt="password.title"
                      ></v-img>
                    </v-avatar>
                    <v-icon v-else icon="mdi mdi-web" size="50"></v-icon>
                    <div class="flex-grow-1">
                      <v-card-title class="pa-0 text-body-1 font-medium">
                        {{ password.title }}
                      </v-card-title>
                      <v-card-subtitle class="pa-0">
                        {{ password.username }}
                      </v-card-subtitle>
                    </div>
                  </div>
                  <div class="mt-2 text-sm">Last updated {{ password.updated_at }}</div>
                </v-card-item>
              </v-card>
            </v-col>
          </template>
        </v-row>
        <template #empty />
      </v-infinite-scroll>
    </template>
  </Dashboard>

  <ShowAndEdit ref="showAndEditRef" :password="selectedPassword" />
  <NewPassword ref="newPasswordRef" />
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { storeToRefs } from 'pinia';
import Dashboard from '@/views/safezone_app/Dashboard.vue';
import NewPassword from '@/views/safezone_app/password/New.vue';
import { usepasswordstore } from '@/stores/safezone_app/password.store';
import ShowAndEdit from '@/components/safezone_app/password/ShowAndEdit.vue';

const selectedPassword = ref(null);
const { passwords, pagination, search, page, totalPages } = storeToRefs(usepasswordstore());
const { fetchpasswords, fetchMorePasswords } = usepasswordstore();

onMounted(async () => {
  await fetchpasswords();
});

const newPasswordRef = ref(null);
const showAndEditRef = ref(false);

const selectPassword = (password = {}) => {
  selectedPassword.value = { ...password };
  showAndEditRef.value.dialog = true;
};

const searchPasswords = async () => {
  await fetchpasswords();
};

// Infinite Scroll - Load More Articles
async function fetchMoreData({ done }) {
  if (page.value < totalPages.value) {
    try {
      page.value += 1;
      const moveArticles = await fetchMorePasswords();
      if (moveArticles.length) {
        passwords.value.push(...moveArticles);
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
