<template>
  <div class="pt-[150px] flex justify-center items-center">
    <v-sheet
      border="md"
      class="pa-6 text-white mx-auto !rounded-md"
      color="#141518"
      width="700"
      max-width="800"
    >
      <div class="text-center">
        <h2>Forgot Password</h2>
        <p class="my-4">Enter your email to reset your password</p>
      </div>
      <v-form @submit.prevent="submit">
        <v-text-field
          v-model="user.email"
          type="email"
          label="Email"
        ></v-text-field>

        <v-btn class="mt-2" type="submit" block>Reset Password</v-btn>
      </v-form>
    </v-sheet>
  </div>
</template>

<script setup lang="ts">
import { reactive } from 'vue';
import { IUserForgotPassword } from '@/types/general';
import { showToast } from '@/utils/showToast';
import { useAuthStore } from '@/stores/auth.store';
import { useUserStore } from '@/stores/user.store';

const authStore = useAuthStore();
const { forgotPassword } = useUserStore();

const user = reactive<IUserForgotPassword>({
  email: '',
});

const submit = async() => {
  try {
    await forgotPassword(user)
    showToast('Password reset email sent!', 'success');
  } catch (error) {
    showToast(error.message, 'error');
  }
};
</script>
