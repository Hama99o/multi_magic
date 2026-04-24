<template>
  <v-container class="mt-8">
    <v-text-field
      v-model="title"
      label="Enter Title"
      class="mb-4"
    ></v-text-field>
    <v-btn @click="fetchDraft" class="bg-blue-500 text-white">Fetch Draft</v-btn>

    <v-card class="mt-4" v-if="loading">
      <v-card-text>Loading...</v-card-text>
    </v-card>

    <v-card v-if="response.length" class="mt-4">
      <v-card-title>Response</v-card-title>
      <v-card-text>
        <ul v-html="response">
        </ul>
      </v-card-text>
    </v-card>
  </v-container>
</template>

<script setup>
import { ref } from 'vue';
import { http, setHTTPHeader } from '@/services/http.service';

const title = ref('');
const response = ref('');
const loading = ref(false);

const fetchDraft = async () => {
  if (!title.value) {
    alert('Please enter a title!');
    return;
  }

  loading.value = true; // Show loading state
  response.value = ''; // Clear previous responses

  try {
    const token = localStorage.getItem('token');
    const url = `/api/v1/ai/show`; // Replace with your POST endpoint
    // Using fetch for streaming
    const res = await fetch(url, {
      method: 'POST', // Use POST method
      headers: {
        'Authorization': token, // Set your token here
        'Content-Type': 'application/json', // Sending JSON data
        'Accept': 'text/event-stream' // Important for SSE streaming
      },
      body: JSON.stringify({ title: title.value }) // Send title as part of the request body
    });


    const reader = res.body.getReader();
    const decoder = new TextDecoder('utf-8');
    let done = false;

    while (!done) {
      const { value, done: readerDone } = await reader.read();
      done = readerDone;
      if (value) {
        const chunk = decoder.decode(value, { stream: !readerDone });
        response.value += chunk; // Append the new token to response
      }
    }
  } catch (error) {
    console.error('Error fetching data:', error);
  } finally {
    loading.value = false; // Hide loading state
  }
};
</script>


<style scoped>
/* You can add additional styles here if needed */
</style>
