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
            class="cursor-pointer hover:border-primary h-[119px]"
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
          <v-avatar size="48" rounded="lg">
            <v-img
              :src="`https://www.google.com/s2/favicons?domain=${selectedPassword.link}&sz=64`"
              :alt="selectedPassword.title"
            ></v-img>
          </v-avatar>
          <div>
            <v-card-title class="pa-0 text-xl font-semibold">
              {{ selectedPassword.title }}
            </v-card-title>
            <v-card-subtitle class="pa-0">
              {{ selectedPassword.link }}
            </v-card-subtitle>
          </div>
        </div>
      </v-card-item>

      <v-card-text>
        <v-form class="space-y-3">
          <v-text-field
            v-if="selectedPassword.username"
            v-model="selectedPassword.username"
            label="Username"
            readonly
            append-inner-icon="mdi-content-copy"
            variant="outlined"
            density="comfortable"
            hide-details
            @click:append-inner="copyToClipboard(selectedPassword.username)"
          ></v-text-field>

          <v-text-field
            v-if="selectedPassword.email"
            v-model="selectedPassword.email"
            label="Email"
            readonly
            append-inner-icon="mdi-content-copy"
            variant="outlined"
            hide-details
            density="comfortable"
            @click:append-inner="copyToClipboard(selectedPassword.email)"
          ></v-text-field>

          <v-text-field
            v-if="selectedPassword.password"
            v-model="selectedPassword.password"
            label="Password"
            :type="showPassword ? 'text' : 'password'"
            readonly
            :append-inner-icon="showPassword ? 'mdi-eye-off' : 'mdi-eye'"
            variant="outlined"
            density="comfortable"
            hide-details
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

          <!-- Website Field -->
          <v-text-field
            v-if="selectedPassword.link"
            v-model="selectedPassword.link"
            label="Website"
            readonly
            append-inner-icon="mdi-open-in-new"
            variant="outlined"
            density="comfortable"
            hide-details
            @click:append-inner="openWebsite(selectedPassword.link)"
          ></v-text-field>

          <div v-if="selectedPassword.password" class="my-4">
            <div class="d-flex justify-space-between mb-2 text-sm">
              <span>Password strength</span>
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
            v-if="selectedPassword.note"
            v-model="selectedPassword.note"
            label="Notes"
            readonly
            variant="outlined"
            rows="4"
            hide-details
          ></v-textarea>
        </v-form>
      </v-card-text>

      <v-card-actions class="mx-[16px] flex">
        <v-btn color="error" variant="outlined" @click="removePassword"> Delete </v-btn>
        <v-spacer></v-spacer>
        <v-btn color="primary" variant="outlined" @click="editPassword"> Edit </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>

  <newPassword ref="newPasswordRef"/>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { storeToRefs } from 'pinia';
import Dashboard from '@/views/safezone_app/Dashboard.vue';
import newPassword from '@/views/safezone_app/password/New.vue';
const showPasswordDetail = ref(false);
const showPassword = ref(false);
const selectedPassword = ref(null);
import { usepasswordstore } from '@/stores/safezone_app/password.store';

const { passwords } = storeToRefs(usepasswordstore());
const { fetchpasswords, deletePassword } = usepasswordstore();

onMounted(async () => {
  await fetchpasswords();
});

const newPasswordRef = ref(null)

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

const removePassword = async () => {
  await deletePassword(selectedPassword.value?.id)
  showPasswordDetail.value = false;
};

const openWebsite = (url) => {
  if (url && !url.startsWith('http')) {
    url = `https://${url}`;
  }
  window.open(url, '_blank');
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
