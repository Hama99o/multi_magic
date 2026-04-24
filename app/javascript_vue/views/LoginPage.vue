<template>
  <div class="pt-[50px] flex justify-center items-center">
    <v-sheet
      v-if="!loggedIn"
      border="md"
      class="pa-6 text-white mx-auto !rounded-md"
      color="#141518"
      width="700"
      max-width="800"
    >
      <div class="text-center">
        <h2>Welcome, User!</h2>
        <p class="my-4">Please log in</p>
      </div>

      <!-- Error Message -->
      <div v-if="error" class="text-red-500 text-center mb-4">
        {{ error }}
      </div>

      <v-form fast-fail @submit.prevent="submit">
        <!-- Email Field -->
        <v-text-field
          v-model="user.email"
          type="email"
          label="Email"
          outlined
          class="mb-4"
          :disabled="loading"
          :error="!!errors.email"
          :error-messages="errors.email"
        ></v-text-field>

        <!-- Password Field -->
        <v-text-field
          v-model="user.password"
          :type="showPassword ? 'text' : 'password'"
          label="Password"
          outlined
          class="mb-4"
          :disabled="loading"
          :error="!!errors.password"
          :error-messages="errors.password"
          :append-icon="!showPassword ? 'mdi-eye' : 'mdi-eye-off'"
          @click:append="showPassword = !showPassword"
        ></v-text-field>

        <!-- Loading Spinner -->
        <div class="flex justify-center items-center">
          <v-progress-circular
            v-if="loading"
            indeterminate
            color="blue"
            size="30"
            class="mb-4"
          ></v-progress-circular>
        </div>

        <!-- Submit Button -->
        <v-btn class="mt-2" type="submit" block :disabled="loading">
          Continue
        </v-btn>

        <p class="message my-5 text-blue underline" @click="resetPassword" style="cursor: pointer">
          Forgot password
        </p>
        <p class="message">
          Not registered?
          <router-link to="/signup" tag="span" style="cursor: pointer" class="text-blue underline">
            Create an account
          </router-link>
        </p>
      </v-form>
      <v-btn variant="outlined" class="w-full mt-9" @click="connect">
        <div class="w-full flex items-center gap-4 normal-case">
          <div>
            <Icon icon="flat-color-icons:google" height="16" width="16" />
          </div>

          <svn-text xs medium>Sign in with Google</svn-text>
        </div>
      </v-btn>
    </v-sheet>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref, onMounted, computed } from 'vue';
import { useAuthStore } from '@/stores/auth.store';
import { IUserLogin } from '@/types/general';
import { showToast } from '@/utils/showToast';
import { useRouter, useRoute } from 'vue-router';
import { googleSdkLoaded } from 'vue3-google-login';
import { API_URL, GOOGLE_CLIENT_ID } from '@/utils/configs';
import { setHTTPHeader } from '@/services/http.service';

const router = useRouter();
const route = useRoute();

const authStore = useAuthStore();

const showPassword = ref(false)
const user = reactive<IUserLogin>({
  email: '',
  password: '',
});

const loading = ref(false);
const error = ref('');
const errors = reactive({
  email: '',
  password: '',
});

const connect = () => {
  loading.value = true;
  googleSdkLoaded((google) => {
    google.accounts.oauth2
      .initCodeClient({
        client_id: GOOGLE_CLIENT_ID,
        scope: 'email profile openid',
        redirect_uri: `${API_URL}/google/callback`,
        ux_mode: 'redirect',
      })
      .requestCode();
  });
};

const loggedIn = computed(() => authStore.isAuthenticated);

const resetPassword = () => {
  router.push({ name: 'forget_password' });
};

const validateFields = () => {
  // Clear previous errors
  errors.email = '';
  errors.password = '';

  let isValid = true;

  if (!user.email) {
    errors.email = 'Email is required.';
    isValid = false;
  }

  if (!user.password) {
    errors.password = 'Password is required.';
    isValid = false;
  }

  return isValid;
};

const submit = () => {
  error.value = '';

  if (!validateFields()) {
    return;
  }

  loading.value = true;
  authStore
    .login(user)
    .then(() => {
      loading.value = false;
      window.location.href = '/'; // Redirect to the dashboard or home panel
    })
    .catch((err) => {
      loading.value = false;
      // error.value = err || 'An error occurred. Please try again later.';
      showToast("Invalid email or password", 'error');
    });
};

onMounted(() => {
  if (route.query?.creds && route.query?.user) {
    localStorage.setItem('user', route.query.user);
    localStorage.setItem('token', route.query.creds);
    setHTTPHeader({ Authorization: route.query.creds });
    window.location.href = '/'; // Redirect if already logged in
  }
});
</script>
