<template>
  <div class="pt-[150px] flex justify-center items-center">
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
          type="password"
          label="Password"
          outlined
          class="mb-4"
          :disabled="loading"
          :error="!!errors.password"
          :error-messages="errors.password"
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
    </v-sheet>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref, onMounted, computed } from 'vue';
import { useAuthStore } from '@/stores/auth.store';
import { IUserLogin } from '@/types/general';
import { showToast } from '@/utils/showToast';
import { useRouter } from 'vue-router';

const router = useRouter();
const authStore = useAuthStore();

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
  if (loggedIn.value) {
    // window.location.href = '/'; // Redirect if already logged in
  }
});
</script>
