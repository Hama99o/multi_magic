<template>
  <v-app>
    <v-main class="bg-gray-50">
      <!-- Hero Section -->
      <section class="bg-gradient-to-r from-blue-600 to-purple-600 text-white py-20">
        <v-container>
          <v-row align="center" justify="center">
            <v-col cols="12" md="4" class="text-center">
              <v-avatar size="200" class="mb-4 border-4 border-white">
                <v-img src="https://github.com/Hama99o.png" alt="Hammayoun Safi"></v-img>
              </v-avatar>
              <h1 class="text-3xl font-bold mb-2">Hammayoun Safi</h1>
              <p class="text-xl mb-4">Fullstack Developer</p>
              <div class="flex justify-center gap-4">
                <v-btn
                  href="https://github.com/Hama99o"
                  target="_blank"
                  icon="mdi-github"
                  variant="text"
                  color="white"
                ></v-btn>
                <v-btn
                  href="mailto:hmmshl@gmail.com"
                  target="_blank"
                  icon="mdi-email"
                  variant="text"
                  color="white"
                ></v-btn>
              </div>
            </v-col>
          </v-row>
        </v-container>
      </section>

      <!-- Current Role -->
      <section class="py-12">
        <v-container>
          <v-row justify="center">
            <v-col cols="12" md="8">
              <v-card>
                <v-card-text>
                  <div class="flex items-center gap-4 mb-4">
                    <v-icon icon="mdi-briefcase" size="large" color="primary"></v-icon>
                    <div>
                      <h3 class="text-xl font-semibold">Learn by Seven</h3>
                      <p class="text-gray-600">Fullstack Developer (2023 - Present)</p>
                    </div>
                  </div>
                  <p>Developing learning management system and company task/interview system using Vue.js and Ruby on Rails.</p>
                </v-card-text>
              </v-card>

              <!-- Skills -->
              <!-- <v-card>
                <v-card-text>
                  <h3 class="text-xl font-semibold mb-4">Technical Skills</h3>
                  <div class="flex flex-wrap gap-2 justify-center">
                    <v-chip v-for="skill in skills" :key="skill" color="primary" variant="outlined">
                      {{ skill }}
                    </v-chip>
                  </div>
                </v-card-text>
              </v-card> -->
            </v-col>
          </v-row>
        </v-container>
      </section>

      <!-- Contact -->
      <section class="bg-gray-100 py-12">
        <v-container>
          <v-row justify="center">
            <v-col cols="12" md="8" class="text-center">
              <h2 class="text-2xl font-bold mb-6">Contact</h2>
              <div class="flex justify-center gap-4">
                <v-btn
                  href="mailto:hmmshl@gmail.com"
                  prepend-icon="mdi-email"
                  color="primary"
                >
                  hmmshl@gmail.com
                </v-btn>
                <v-btn
                  href="tel:+33766666233"
                  prepend-icon="mdi-phone"
                  color="primary"
                  variant="outlined"
                >
                  +33 7 66 66 62 33
                </v-btn>
              </div>
            </v-col>
          </v-row>
        </v-container>
      </section>
    </v-main>
  </v-app>
</template>

<script setup>
const skills = [
  'Vue.js',
  'Ruby on Rails',
  'JavaScript',
  'PostgreSQL',
  'Git',
  'API Development',
  'HTML/CSS',
  'Bootstrap'
]
</script>

<style scoped>
.v-avatar {
  border: 4px solid white;
  box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
}
</style>