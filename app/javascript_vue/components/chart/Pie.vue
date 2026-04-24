<template>
  <div class="bg-white rounded flex flex-col items-center p-3 !h-[500px] !w-[500px]" :class="data.length ? 'justify-center' : ''">
    <div v-if="withSelect">
      <!-- Chart Type Selector -->
      <div>
        Total amount spent on <b>{{ chartSelectOption }}</b>: <b>{{ humanReadableCurrency(totalAmount) }}</b>
      </div>
      <v-select
        :model-value="chartSelectOption"
        density="comfortable"
        :items="tags"
        class="p-2 !w-[300px] !h-[100px] "
        dense
        item-value="id"
        item-title="name"
        outlined
        return-object
        @update:model-value="$emit('update-subcategories-chart-option', $event)"
      />
    </div>
    <div v-if="data.length">
      <Pie
        :data="chartData"
        :chartOptions="chartOptions"
      />
    </div>
    <div v-else>
      <p>No data to display</p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { Pie } from 'vue-chartjs'
import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  ArcElement,
  CategoryScale,
} from 'chart.js'

// Register required components for Chart.js
ChartJS.register(Title, Tooltip, Legend, ArcElement, CategoryScale)

const props = defineProps({
  data: { type: Array, default: () => [] },
  withSelect: { type: Boolean, default: false },
  tags: { type: Array, default: () => [] },
  totalAmountFormatted: { type: Number, default: 0 },
  chartSelectOption: { type: String, default: '' }
});

const chartData = computed(() => {
  return {
    labels: props.data?.map(expense => expense.category),
    datasets: [
      {
        label: 'Expense Distribution',
        backgroundColor: ['#FF6384', '#36A2EB', '#FFCE56', '#FF6384', '#36A2EB', '#FFCE56', '#FF6384', '#36A2EB', '#FFCE56', '#FF6384', '#36A2EB', '#FFCE56'],
        borderWidth: 1,
        data: props.data?.map(expense => expense.amount),
      },
    ],
    }
})

const totalAmount = computed(() => {
  return props.totalAmountFormatted
})

const chartOptions = ref({
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      position: 'top',
    },
    tooltip: {
      callbacks: {
        label: function (tooltipItem) {
          return tooltipItem.label + ': $' + tooltipItem.raw
        },
      },
    },
  },
})

// Function to convert the object into a human-readable format
function humanReadableCurrency(object) {
  var stringMessage = ''
  Object.entries(object).forEach(([currency, amount]) => {
    stringMessage = stringMessage + `${currency} ${amount} `;
  });
  return stringMessage
}
</script>