<template>
  <v-app>
    <v-main>
      <div class="font-sans leading-normal tracking-normal">
        <!-- Hero Section -->
        <section class="py-20 bg-surface">
          <v-container class="text-center">
            <v-row>
              <v-col>
                <v-card class="elevation-0 flex flex-col gap-4">
                  <v-card-title class="text-h2 font-weight-bold">The Ultimate Note Taking Experience</v-card-title>
                  <v-card-text class="text-h5">Organize your thoughts, ideas, and tasks effortlessly with NoteApp.</v-card-text>
                  <div>
                    <v-btn v-if="!currentUser" :to="{ name: 'signup' }" color="yellow darken-1" class="blue--text text-lg font-semibold hover:bg-yellow-300">Get Started</v-btn>
                  <v-btn v-else :to="{ name: 'notes' }" color="yellow darken-1" class="blue--text text-lg font-semibold hover:bg-yellow-300">Get Started</v-btn>
                  </div>
                </v-card>
              </v-col>
            </v-row>
          </v-container>
        </section>

        <!-- Features Section -->
        <section id="features" class="py-20">
          <v-container class="text-center">
            <v-row>
              <v-col cols="12">
                <h2 class="text-4xl font-bold mb-12">Features</h2>
              </v-col>
              <v-col v-for="feature in features" :key="feature.title" cols="12" md="6" lg="4" class="mb-4">
                <v-card class="elevation-2">
                  <v-card-title class="text-2xl font-semibold">{{ feature.title }}</v-card-title>
                  <v-card-text>{{ feature.description }}</v-card-text>
                </v-card>
              </v-col>
            </v-row>
          </v-container>
        </section>

        <!-- FAQ Section -->
        <section id="faq" class="py-20 bg-surface">
          <v-container class="text-center">
            <v-row>
              <v-col cols="12">
                <h2 class="text-4xl font-bold mb-12">Frequently Asked Questions</h2>
              </v-col>
              <v-col v-for="faq in faqs" :key="faq.question" cols="12" md="6" class="mb-4">
                <v-card class="elevation-2">
                  <v-card-title class="text-2xl font-semibold">{{ faq.question }}</v-card-title>
                  <v-card-text>{{ faq.answer }}</v-card-text>
                </v-card>
              </v-col>
            </v-row>
          </v-container>
        </section>

        <!-- Footer with Privacy Policy link -->
        <v-container class="text-center">
          <p>© 2024 Multi Magic. All rights reserved.</p>
          <v-btn text color="yellow lighten-2"
            :to="{
              name: 'policy',
            }"
          >Privacy Policy</v-btn>
        </v-container>
      </div>
    </v-main>
  </v-app>
</template>

<script setup lang="ts">
import { ref, onBeforeUnmount } from 'vue';
import { storeToRefs } from 'pinia';
import { useUserStore } from '@/stores/user.store';

const { currentUser } = storeToRefs(useUserStore());

const features = ref([
  { title: 'Add Pictures', description: 'Easily add and organize images within your notes.' },
  { title: 'Color-Coded Titles', description: 'Organize notes with color-coded titles for easy identification.' },
  { title: 'Checklists', description: 'Create and manage checklists to keep track of your tasks.' },
  { title: 'Ordered & Unordered Lists', description: 'Use ordered and unordered lists to organize your notes.' },
  { title: 'Tagging', description: 'Tag notes for better organization and quick access.' },
  { title: 'Collaboration', description: 'Share and collaborate on notes with others in real-time.' },
]);

const faqs = ref([
  { question: 'What is NoteApp?', answer: 'NoteApp is an advanced note-taking application designed to help you organize your thoughts, ideas, and tasks effortlessly.' },
  { question: 'How do I add images to my notes?', answer: 'You can add images to your notes by clicking the "Add Image" button in the note editor.' },
  { question: 'Can I share my notes with others?', answer: 'Yes, you can share and collaborate on notes with others in real-time.' },
]);

const pageName = 'Index';
</script>

