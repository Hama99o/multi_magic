<template>
  <v-app>
    <v-main>
      <!-- Hero Section with Animated Background -->
      <section
        class="relative overflow-hidden bg-gradient-to-r from-purple-900 to-blue-900 text-white"
      >
        <div
          class="absolute inset-0 animate-pulse bg-[url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjIwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48ZGVmcz48cGF0dGVybiBpZD0iZ3JpZCIgd2lkdGg9IjIwIiBoZWlnaHQ9IjIwIiBwYXR0ZXJuVW5pdHM9InVzZXJTcGFjZU9uVXNlIj48cGF0aCBkPSJNIDIwIDAgTCAwIDAgMCAyMCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJyZ2JhKDI1NSwyNTUsMjU1LDAuMSkiIHN0cm9rZS13aWR0aD0iMSIvPjwvcGF0dGVybj48L2RlZnM+PHJlY3Qgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgZmlsbD0idXJsKCNncmlkKSIvPjwvc3ZnPg==')] opacity-30"
        ></div>
        <v-container class="relative py-20">
          <v-row align="center" justify="center">
            <v-col cols="12" md="8" class="text-center">
              <h1 class="animate-fade-in mb-6 text-5xl font-bold md:text-6xl">Multi Magic</h1>
              <p class="animate-slide-up mb-8 text-xl md:text-2xl">
                Your All-in-One Productivity Suite
              </p>
              <v-btn
                v-if="!currentUser"
                :to="{ name: 'signup' }"
                size="x-large"
                color="primary"
                class="animate-bounce-subtle text-lg font-semibold"
              >
                Get Started
              </v-btn>
            </v-col>
          </v-row>
        </v-container>
      </section>

      <!-- Apps Showcase Section with Detailed Information -->
      <section class="bg-info py-4">
        <v-container>
          <h2 class="mb-8 text-center text-3xl font-bold md:text-4xl">Our Applications</h2>
          <v-row>
            <v-col v-for="(app, index) in apps" :key="app.title" cols="12" lg="6">
              <v-hover v-slot="{ isHovering, props }">
                <v-card
                  v-bind="props"
                  :elevation="isHovering ? 8 : 2"
                  class="h-full transition-all duration-500"
                  :class="{
                    'scale-105 transform': isHovering,
                    'animate-slide-in': true,
                  }"
                  :style="{ animationDelay: `${index * 100}ms` }"
                >
                  <v-row>
                    <v-col cols="12" md="4" class="d-flex align-center pa-6 justify-center">
                      <v-icon
                        :icon="app.icon"
                        size="64"
                        :color="app.color"
                        class="transition-transform duration-300"
                        :class="{ 'rotate-12': isHovering }"
                      ></v-icon>
                    </v-col>
                    <v-col cols="12" md="8" class="pa-6">
                      <v-card-title class="mb-2 text-2xl font-bold">{{ app.title }}</v-card-title>
                      <v-card-text>
                        <p class="mb-4">{{ app.description }}</p>
                        <v-list class="pa-0 bg-transparent">
                          <v-list-item v-for="feature in app.features" :key="feature" class="px-0">
                            <template #prepend>
                              <v-icon icon="mdi-check" color="success" size="small"></v-icon>
                            </template>
                            {{ feature }}
                          </v-list-item>
                        </v-list>
                      </v-card-text>
                      <v-card-actions>
                        <v-btn
                          :to="app.route"
                          color="primary"
                          variant="tonal"
                          block
                          class="transition-transform duration-300"
                          :class="{ 'scale-105': isHovering }"
                        >
                          Launch {{ app.title }}
                        </v-btn>
                      </v-card-actions>
                    </v-col>
                  </v-row>
                </v-card>
              </v-hover>
            </v-col>
          </v-row>
        </v-container>
      </section>

      <!-- Features Section with Animations -->
      <section class="relative overflow-hidden py-16">
        <div
          class="absolute inset-0 bg-gradient-to-b from-transparent to-gray-100 opacity-50"
        ></div>
        <v-container class="relative">
          <h2 class="mb-12 text-center text-3xl font-bold md:text-4xl">Why Choose Multi Magic?</h2>
          <v-row>
            <v-col v-for="(feature, index) in features" :key="feature.title" cols="12" md="4">
              <div
                class="rounded-lg px-4 py-6 text-center transition-all duration-300 hover:bg-info"
                :class="{ 'animate-fade-in': true }"
                :style="{ animationDelay: `${index * 200}ms` }"
              >
                <v-icon
                  :icon="feature.icon"
                  size="48"
                  :color="feature.color"
                  class="animate-float mb-4"
                ></v-icon>
                <h3 class="mb-2 text-xl font-semibold">{{ feature.title }}</h3>
                <p>{{ feature.description }}</p>
              </div>
            </v-col>
          </v-row>
        </v-container>
      </section>

      <!-- Stats Section -->
      <section class="bg-accent py-16">
        <v-container>
          <v-row class="flex justify-center">
            <v-col v-for="stat in stats" :key="stat.label" cols="6" md="3">
              <div class="animate-count-up text-center">
                <div class="mb-2 text-4xl font-bold">{{ stat.value }}</div>
                <div>{{ stat.label }}</div>
              </div>
            </v-col>
          </v-row>
        </v-container>
      </section>

      <!-- Enhanced Footer -->
      <v-footer class="bg-primary">
        <v-container>
          <v-row>
            <v-col cols="12" md="4">
              <h3 class="mb-4 text-xl font-bold">Multi Magic</h3>
              <p>
                Your complete productivity solution for notes, contacts, blogs, passwords, and
                finances.
              </p>
              <div class="mt-4 flex space-x-4">
                <v-btn icon variant="text" href="https://gitlab.com/Hama99o" target="_blank">
                  <v-icon>mdi mdi-gitlab</v-icon>
                </v-btn>
                <v-btn icon variant="text" href="https://github.com/Hama99o" target="_blank">
                  <v-icon>mdi-github</v-icon>
                </v-btn>
                <v-btn icon variant="text" href="https://www.linkedin.com/in/hammayoun-safi-2916581bb/" target="_blank">
                  <v-icon>mdi-linkedin</v-icon>
                </v-btn>
              </div>
            </v-col>
            <v-col cols="12" md="4">
              <h3 class="mb-4 text-xl font-bold">Quick Links</h3>
              <v-list bg-color="transparent" class="pa-0">
                <v-list-item v-for="app in apps" :key="app.title" :to="app.route" class="px-0">
                  <template #prepend>
                    <v-icon :icon="app.icon" size="small" class="mr-2"></v-icon>
                  </template>
                  {{ app.title }}
                </v-list-item>
              </v-list>
            </v-col>
            <v-col cols="12" md="4">
              <h3 class="mb-4 text-xl font-bold">Legal</h3>
              <v-list bg-color="transparent" class="pa-0">
                <v-list-item to="/policy" class="px-0">Privacy Policy</v-list-item>
                <v-list-item to="/policy" class="px-0">Terms of Service</v-list-item>
              </v-list>
            </v-col>
          </v-row>
          <v-divider class="my-6 border-gray-800"></v-divider>
          <div class="text-center">
            © {{ new Date().getFullYear() }} Multi Magic. All rights reserved.
          </div>
        </v-container>
      </v-footer>
    </v-main>
  </v-app>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { storeToRefs } from 'pinia';
import { useUserStore } from '@/stores/user.store';

const { currentUser } = storeToRefs(useUserStore());

const apps = ref([
  {
    title: 'Notes',
    description: 'Organize your thoughts and ideas with our powerful note-taking app.',
    icon: 'mdi-note-outline',
    color: 'blue',
    route: '/note_app/notes?page=all_notes',
    features: [
      'Rich text editor with formatting',
      'File attachments and images',
      'Tags and categories',
      'Collaborative editing',
      'Version history',
    ],
  },
  {
    title: 'Contacts',
    description: 'Manage your contacts efficiently with our contact management system.',
    icon: 'mdi-account-group-outline',
    color: 'green',
    route: '/contact_app/contacts',
    features: [
      'Import/Export contacts',
      'Custom fields and groups',
      'Birthday reminders',
      'Contact history',
      'Quick search and filters',
    ],
  },
  {
    title: 'Blog',
    description: 'Share your stories and insights with our user-friendly blog platform.',
    icon: 'mdi-post-outline',
    color: 'purple',
    route: '/blog_app/articles',
    features: [
      'Markdown support',
      'SEO optimization',
      'Comments and reactions',
      'Analytics dashboard',
      'Social media sharing',
    ],
  },
  {
    title: 'Password Manager',
    description: 'Keep your passwords secure and easily accessible.',
    icon: 'mdi-key-outline',
    color: 'red',
    route: '/safezone_app/passwords',
    features: [
      'End-to-end encryption',
      'Password generator',
      'Secure sharing',
      'Browser extension',
      'Two-factor authentication',
    ],
  },
  {
    title: 'Finance',
    description: 'Track your expenses and manage your financial life.',
    icon: 'mdi-wallet-outline',
    color: 'amber',
    route: '/my_finance_app/expenses',
    features: [
      'Expense tracking',
      'Budget planning',
      'Financial reports',
      'Bill reminders',
      'Multiple currency support',
    ],
  },
]);

const features = ref([
  {
    title: 'Secure',
    description: 'Your data is protected with industry-standard encryption.',
    icon: 'mdi-shield-check-outline',
    color: 'success',
  },
  {
    title: 'Fast',
    description: 'Lightning-fast performance across all our applications.',
    icon: 'mdi-speedometer',
    color: 'info',
  },
  {
    title: 'Integrated',
    description: 'All your tools work seamlessly together in one platform.',
    icon: 'mdi-apps',
    color: 'primary',
  },
]);

const stats = ref([
  // { value: '10K+', label: 'Active Users' },
  // { value: '5M+', label: 'Notes Created' },
  { value: '99.9%', label: 'Uptime' },
  { value: '24/7', label: 'Support' },
]);
</script>

<style scoped>
.v-card {
  border: 1px solid rgba(0, 0, 0, 0.1);
}

.animate-fade-in {
  animation: fadeIn 0.6s ease-out forwards;
}

.animate-slide-up {
  animation: slideUp 0.6s ease-out forwards;
}

.animate-slide-in {
  opacity: 0;
  animation: slideIn 0.6s ease-out forwards;
}

.animate-float {
  animation: float 3s ease-in-out infinite;
}

.animate-bounce-subtle {
  animation: bounceSlight 2s ease-in-out infinite;
}

.hover-lift {
  transition: transform 0.2s ease;
}

.hover-lift:hover {
  transform: translateX(8px);
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateX(-20px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

@keyframes float {
  0%,
  100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-10px);
  }
}

@keyframes bounceSlight {
  0%,
  100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-5px);
  }
}

.v-footer {
  .v-list-item {
    min-height: 35px;
    color: #fff;
    opacity: 0.7;
    transition: all 0.2s ease;

    &:hover {
      opacity: 1;
    }
  }
}
</style>
