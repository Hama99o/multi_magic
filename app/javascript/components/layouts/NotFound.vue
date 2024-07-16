<template>
  <v-container
    class="flex flex-col items-center justify-center text-center text-white p-6"
  >
    <v-row class="w-full">
      <v-col
        cols="12"
        md="8"
        lg="6"
        class="flex flex-col items-center mx-auto"
      >
      <img alt="404" style="width: 520px;" src="@/assets/logos/error-404-no.jpg" class="mr-3 mb-8"/>

        <v-card
          class="py-8 px-6 rounded-xl shadow-lg bg-white text-gray-800 w-full"
        >
          <v-card-title class="text-4xl font-bold mb-4">
            Oops! Page Not Found
          </v-card-title>
          <v-card-text>
            <p class="text-lg mb-6">
              The page you're looking for doesn't exist or has been moved.
            </p>
            <v-btn class="mt-4" color="primary" @click="goHome">
              Go to Home
            </v-btn>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import { useRouter } from 'vue-router';

const router = useRouter();

const goHome = () => {
  router.push('/');
};
</script>
