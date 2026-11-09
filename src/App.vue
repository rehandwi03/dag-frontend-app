<script setup>
import { computed, onMounted, ref } from 'vue'
import { API_BASE_URL, fetchHealth, fetchUsers } from './api'

const health = ref(null)
const users = ref([])
const loading = ref(true)
const error = ref('')
const lastUpdated = ref(null)

const statusLabel = computed(() => {
  if (loading.value) return 'Checking'
  return health.value?.status === 'ok' ? 'Online' : 'Unavailable'
})

const statusClass = computed(() => {
  if (loading.value) return 'pending'
  return health.value?.status === 'ok' ? 'online' : 'offline'
})

const updatedAt = computed(() => {
  if (!lastUpdated.value) return 'Never'
  return lastUpdated.value.toLocaleTimeString()
})

async function load() {
  loading.value = true
  error.value = ''

  try {
    const [healthResponse, usersResponse] = await Promise.all([fetchHealth(), fetchUsers()])
    health.value = healthResponse
    users.value = usersResponse.data ?? []
    lastUpdated.value = new Date()
  } catch (exception) {
    health.value = null
    users.value = []
    error.value = exception.message
  } finally {
    loading.value = false
  }
}

onMounted(load)
</script>

<template>
  <main class="page">
    <header class="hero">
      <div>
        <p class="eyebrow">Sample workload</p>
        <h1>REST API Frontend</h1>
        <p class="subtitle">
          Vue SPA yang membaca data dari Laravel API melalui <code>/api</code>.
        </p>
      </div>

      <div class="status" :class="statusClass">
        <span class="dot"></span>
        <span>{{ statusLabel }}</span>
      </div>
    </header>

    <section class="card">
      <div class="card-header">
        <h2>Backend health</h2>
        <button class="refresh" :disabled="loading" @click="load">
          {{ loading ? 'Loading...' : 'Refresh' }}
        </button>
      </div>

      <p v-if="error" class="error">{{ error }}</p>

      <dl v-else-if="health" class="health-grid">
        <div>
          <dt>Status</dt>
          <dd>{{ health.status }}</dd>
        </div>
        <div>
          <dt>Service</dt>
          <dd>{{ health.service }}</dd>
        </div>
        <div>
          <dt>Server time</dt>
          <dd>{{ new Date(health.timestamp).toLocaleString() }}</dd>
        </div>
        <div>
          <dt>Last checked</dt>
          <dd>{{ updatedAt }}</dd>
        </div>
      </dl>

      <p v-else class="muted">Menunggu respons backend...</p>
    </section>

    <section class="card">
      <div class="card-header">
        <h2>Users</h2>
        <span class="count">{{ users.length }} records</span>
      </div>

      <div class="table-wrap">
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Name</th>
              <th>Email</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="user in users" :key="user.id">
              <td>{{ user.id }}</td>
              <td>{{ user.name }}</td>
              <td>{{ user.email }}</td>
            </tr>
            <tr v-if="!users.length && !loading">
              <td colspan="3" class="muted">Tidak ada data.</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>

    <footer>
      API base: <code>{{ API_BASE_URL }}</code>
    </footer>
  </main>
</template>
