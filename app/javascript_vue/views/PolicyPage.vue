<template>
  <v-app>
    <v-main class="bg-info">
      <v-container class="py-12">
        <v-row>
          <v-col cols="12" lg="3">
            <!-- Table of Contents -->
            <v-card class="mb-6 sticky top-6">
              <v-card-title class="text-h6 font-weight-bold">
                Table of Contents
              </v-card-title>
              <v-card-text>
                <v-list density="compact" nav>
                  <v-list-item
                    v-for="(section, index) in sections"
                    :key="index"
                    :href="`#${section.id}`"
                    :title="section.title"
                    class="rounded"
                  >
                    <template v-slot:prepend>
                      <v-icon :icon="section.icon" color="primary" class="mr-2"></v-icon>
                    </template>
                  </v-list-item>
                </v-list>
              </v-card-text>
            </v-card>
          </v-col>

          <v-col cols="12" lg="9">
            <v-card class="mb-6">
              <v-card-text>
                <h1 class="text-4xl font-bold mb-4">Privacy Policy</h1>
                <p class=" mb-4">
                  This Privacy Policy explains how we collect, use, and share information when you use Multi Magic.
                </p>
                <p class="text-sm ">
                  Last Updated: {{ lastUpdated }}
                </p>
              </v-card-text>
            </v-card>

            <v-card v-for="section in sections" :key="section.id" class="mb-6" :id="section.id">
              <v-card-title class="text-2xl font-semibold d-flex align-center">
                <v-icon :icon="section.icon" color="primary" class="mr-2" size="large"></v-icon>
                {{ section.title }}
              </v-card-title>
              <v-card-text class="text-gray-700">
                <p v-html="section.content"></p>
                <v-list v-if="section.list" class="bg-transparent">
                  <v-list-item v-for="(item, index) in section.list" :key="index" class="px-0">
                    <template v-slot:prepend>
                      <v-icon icon="mdi-check-circle" color="success" size="small"></v-icon>
                    </template>
                    <v-list-item-title class="text-wrap" v-html="item"></v-list-item-title>
                  </v-list-item>
                </v-list>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </v-main>
  </v-app>
</template>

<script setup>
import { ref } from 'vue';

const lastUpdated = ref('May 15, 2023');

const sections = ref([
  {
    id: 'data-collection',
    title: 'Data Collection',
    icon: 'mdi-database',
    content: 'We collect data to provide and improve our services. This includes information you provide directly, data collected automatically, and data from third-party sources. We are committed to transparency in our data collection practices.',
    list: [
      '<b>User Information:</b> Information you provide during account creation and app usage, such as your name, email address, and profile details.',
      '<b>Usage Data:</b> Information about your interaction with our app, including features used, time spent, and preferences.',
      '<b>Cookies and Tracking:</b> We use cookies and similar technologies to enhance user experience, remember preferences, and analyze app usage patterns.',
      '<b>Device Information:</b> Data about the devices you use to access our services, including hardware models, operating systems, and unique device identifiers.'
    ]
  },
  {
    id: 'data-use',
    title: 'Data Use',
    icon: 'mdi-cog',
    content: 'Your data is used to provide and enhance services, customize your experience, and for analytics. We are committed to using your data responsibly and in ways that benefit your user experience.',
    list: [
      '<b>Service Provision:</b> To operate, maintain, and improve our applications and services.',
      '<b>Personalization:</b> To tailor content, recommendations, and features to your preferences and usage patterns.',
      '<b>Communication:</b> To send you important updates, notifications, and marketing communications (with your consent).',
      '<b>Analytics and Research:</b> To understand user behavior, troubleshoot issues, and develop new features.'
    ]
  },
  {
    id: 'data-sharing',
    title: 'Data Sharing',
    icon: 'mdi-share-variant',
    content: 'We may share data with trusted third parties for specific purposes. We ensure all partners adhere to strict data protection standards and only share what is necessary for the intended purpose.',
    list: [
      '<b>Service Providers:</b> We may share data with third-party vendors who help us operate our services (e.g., cloud storage providers, analytics services).',
      '<b>Legal Compliance:</b> We may disclose data if required by law, regulation, or legal process.',
      '<b>Business Transfers:</b> In the event of a merger, acquisition, or sale of assets, user data may be transferred as part of the transaction.',
      '<b>With Your Consent:</b> We may share data with third parties when you have given us explicit consent to do so.'
    ]
  },
  {
    id: 'security',
    title: 'Security',
    icon: 'mdi-shield-check',
    content: 'We prioritize your data security and implement various safeguards to protect it from unauthorized access, use, or disclosure. Our security measures include:',
    list: [
      '<b>Encryption:</b> We use industry-standard encryption to protect data in transit and at rest.',
      '<b>Access Controls:</b> We limit access to personal data to authorized personnel who need it to perform their job functions.',
      '<b>Regular Audits:</b> We conduct regular security audits and assessments to identify and address potential vulnerabilities.',
      '<b>Employee Training:</b> Our staff undergoes regular privacy and security training to ensure best practices are followed.'
    ]
  },
  {
    id: 'changes',
    title: 'Changes to This Policy',
    icon: 'mdi-update',
    content: 'We may update this policy periodically to reflect changes in our practices or for legal, operational, or regulatory reasons. When we make significant changes, we will:',
    list: [
      'Notify users via email or through a prominent notice within our applications.',
      'Update the "Last Updated" date at the top of this policy.',
      'In some cases, we may seek your consent before implementing the changes.'
    ]
  },
  {
    id: 'contact',
    title: 'Contact Us',
    icon: 'mdi-email',
    content: 'If you have questions about this Privacy Policy or our data practices, please don\'t hesitate to reach out. We are committed to addressing your concerns and ensuring transparency in our data handling practices.<br><br>You can contact us at: <a href="mailto:hmmshl@gmail.com" class="text-primary hover:underline">hmmshl@gmail.com</a>'
  }
]);
</script>

<style scoped>
.v-card {
  transition: box-shadow 0.3s ease-in-out;
}

.v-card:hover {
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.sticky {
  position: sticky;
  top: 1.5rem;
}
</style>