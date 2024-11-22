<template>
  <div class="flex flex-col justify-center items-center m-5">
    <div class="text-center">
      <h2 class="text-2xl font-bold">Create Account</h2>
      <p class="my-4 text-gray-400">
        Already have an account?
        <router-link to="/login" tag="span" style="cursor: pointer" class="text-blue-500 underline">
          Sign In
        </router-link>
      </p>
    </div>

    <v-form fast-fail @submit.prevent="submit">
      <!-- Error Message -->
      <div v-if="error" class="text-red-500 text-center mb-4">
        {{ error }}
      </div>

      <!-- First Name Field -->
      <v-text-field
        v-model="user.firstname"
        type="text"
        label="First Name"
        outlined
        :disabled="loading"
        class="mb-4"
        :error="!!errors.firstname"
        :error-messages="errors.firstname"
      ></v-text-field>

      <!-- Last Name Field -->
      <v-text-field
        v-model="user.lastname"
        type="text"
        label="Last Name"
        outlined
        :disabled="loading"
        class="mb-4"
        :error="!!errors.lastname"
        :error-messages="errors.lastname"
      ></v-text-field>

      <!-- Birth Date Field -->
      <date-picker
        ref="dateModal"
        @save="setDueDate"
        :date-value="user.birth_date"
      >
        <template #activator="{ props }">
          <v-text-field
            @click="dateModal.dialog = true"
            v-model="formattedDate"
            label="Birth date"
            outlined
            :disabled="loading"
            :error="!!errors.birth_date"
            :error-messages="errors.birth_date"
          ></v-text-field>
        </template>
      </date-picker>

      <!-- Email Field -->
      <v-text-field
        v-model="user.email"
        type="email"
        label="Email"
        outlined
        :disabled="loading"
        class="mb-4"
        :error="!!errors.email"
        :error-messages="errors.email"
      ></v-text-field>

      <!-- Password Field -->
      <v-text-field
        v-model="user.password"
        :type="showPassword ? 'text' : 'password'"
        label="Password"
        outlined
        :disabled="loading"
        class="mb-4"
        :append-icon="!showPassword ? 'mdi-eye' : 'mdi-eye-off'"
        @click:append="showPassword = !showPassword"
        :error="!!errors.password"
        :error-messages="errors.password"
      ></v-text-field>

      <!-- Password Confirmation Field -->
      <v-text-field
        v-model="user.password_confirmation"
        :type="showConfirmationPassword ? 'text' : 'password'"
        label="Verify Password"
        outlined
        :disabled="loading"
        class="mb-4"
        :error="!!errors.password_confirmation"
        :append-icon="!showConfirmationPassword ? 'mdi-eye' : 'mdi-eye-off'"
        @click:append="showConfirmationPassword = !showConfirmationPassword"
        :error-messages="errors.password_confirmation"
      ></v-text-field>

      <!-- Checkbox and Terms Link -->
      <v-checkbox
        class="mt-4"
        v-model="user.agreed_to_terms"
        :disabled="loading"
        color="blue"
      >
        <template v-slot:label>
          <p class="text-gray-300">
            I have read and agree to
            <span @click.prevent="renderToTerms" style="cursor: pointer" class="text-blue-500 underline">
              the Terms of Service
            </span>
          </p>
        </template>
      </v-checkbox>

      <div class="flex justify-center items-center">
        <!-- Loading Spinner -->
        <v-progress-circular
          v-if="loading"
          indeterminate
          color="blue"
          size="30"
          class="mb-4"
        ></v-progress-circular>
      </div>

      <v-btn
        class="mt-4"
        v-if="!loading"
        type="submit"
        block
        :disabled="loading"
        color="blue darken-1"
      >
        Continue
      </v-btn>
    </v-form>
    <v-btn variant="outlined" class="w-full mt-8" @click="connect">
      <div class="w-full flex items-center gap-4 normal-case">
        <div>
          <Icon icon="flat-color-icons:google" height="16" width="16" />
        </div>

        <svn-text xs medium>Sign up with Google</svn-text>
      </div>
    </v-btn>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/auth.store';
import { IRegisterUser } from '@/types/general';
import { showToast } from '@/utils/showToast';
import DatePicker from '@/components/tools/DatePicker.vue';
import moment from "moment";
import { useUserStore } from '@/stores/user.store';
import { storeToRefs } from 'pinia';
import { googleSdkLoaded } from 'vue3-google-login';
import { API_URL, GOOGLE_CLIENT_ID } from '@/utils/configs';

const { currentUser } = storeToRefs(useUserStore());
const router = useRouter();
const authStore = useAuthStore();

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

onMounted(() => {
  if (currentUser.value?.id) router.push({ name: 'index' }); // Change 'index' to the name of the route you want to redirect to
});

const loading = ref(false);
const error = ref('');
const dateModal = ref(false);
const showConfirmationPassword = ref(false)
const showPassword = ref(false)

const errors = reactive({
  firstname: '',
  lastname: '',
  birth_date: '',
  email: '',
  password: '',
  password_confirmation: ''
});

const user = reactive<IRegisterUser>({
  firstname: '',
  lastname: '',
  birth_date: '',
  email: '',
  password: '',
  password_confirmation: '',
  agreed_to_terms: false,
});

const setDueDate = (e) => {
  user.birth_date = e
};

const formattedDate = computed(() => {
  return user.birth_date ? moment(user.birth_date).format('YYYY-MM-DD') : '';
});

// Function to check if the password is strong
const isPasswordStrong = (password: string) => {
  const minLength = /.{8,}/;
  const hasUppercase = /[A-Z]/;
  const hasLowercase = /[a-z]/;
  const hasDigit = /\d/;
  const hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/;

  return (
    minLength.test(password) &&
    hasUppercase.test(password) &&
    hasLowercase.test(password) &&
    hasDigit.test(password) &&
    hasSpecialChar.test(password)
  );
};

const validateFields = () => {
  // Clear previous errors
  errors.firstname = '';
  errors.lastname = '';
  errors.birth_date = '';
  errors.email = '';
  errors.password = '';
  errors.password_confirmation = '';

  let isValid = true;

  if (!user.firstname) {
    errors.firstname = 'First name is required.';
    isValid = false;
  }

  if (!user.lastname) {
    errors.lastname = 'Last name is required.';
    isValid = false;
  }

  if (!user.birth_date) {
    errors.birth_date = 'Birth date is required.';
    isValid = false;
  } else {
    user.birth_date = moment(user.birth_date).format('YYYY-MM-DD')
  }

  if (!user.email) {
    errors.email = 'Email is required.';
    isValid = false;
  }

  if (!user.password) {
    errors.password = 'Password is required.';
    isValid = false;
  } else if (!isPasswordStrong(user.password)) {
    errors.password = 'Password must be at least 8 characters long and include uppercase, lowercase, number, and special character.';
    isValid = false;
  }

  if (!user.password_confirmation) {
    errors.password_confirmation = 'Password confirmation is required.';
    isValid = false;
  } else if (user.password !== user.password_confirmation) {
    errors.password_confirmation = 'Passwords do not match.';
    isValid = false;
  }

  return isValid;
};

const submit = () => {
  // Reset general error
  error.value = '';

  // Check if fields are valid
  if (!validateFields()) {
    return;
  }

  // Check if terms are accepted
  if (!user.agreed_to_terms) {
    error.value = 'You must accept the terms and conditions.';
    return;
  }

  loading.value = true;
  authStore.register(user).then(
    (res) => {
      const message = res?.data.messages?.[0]
      if (message) showToast(message, 'error');
      loading.value = false;
      router.push({ name: 'login' });
    },
    (err) => {
      loading.value = false;
      error.value = err || 'An error has occurred. Please try again later.';
      showToast(error.value, 'error');
    }
  );
};

const renderToTerms = () => {
  // Logic to render terms
  console.log('Redirecting to Terms of Service...');
};

</script>
