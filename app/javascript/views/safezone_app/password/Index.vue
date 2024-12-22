<template>
  <Dashboard>
    <template #container>
      <div class="d-flex justify-space-between align-center mb-6 flex-wrap">
        <h2 class="mb-sm-0 mb-2 text-2xl font-semibold">Passwords</h2>
        <v-btn color="primary" prepend-icon="mdi-plus" @click="newPasswordRef.dialog = true">
          Add New
        </v-btn>
      </div>

      <!-- Passwords Section -->
      <v-row>
        <v-col v-for="password in passwords" :key="password.id" cols="12" sm="6" md="4" lg="3">
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
                <v-icon v-else icon="mdi mdi-star-four-points-box" size="50"></v-icon>
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
      </v-row>
    </template>
  </Dashboard>

  <ShowAndEdit ref="showAndEditRef" :password="selectedPassword"/>
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
const { passwords } = storeToRefs(usepasswordstore());
const { fetchpasswords } = usepasswordstore();

onMounted(async () => {
  await fetchpasswords();
});

const newPasswordRef = ref(null);
const showAndEditRef = ref(false);

const selectPassword = (password = {}) => {
  selectedPassword.value = { ...password };
  showAndEditRef.value.dialog = true;
};
</script>
