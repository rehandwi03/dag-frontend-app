const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '/api'

async function request(path) {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    headers: { Accept: 'application/json' },
  })

  if (!response.ok) {
    throw new Error(`Request to ${path} failed with status ${response.status}`)
  }

  return response.json()
}

export function fetchHealth() {
  return request('/health')
}

export function fetchUsers() {
  return request('/users')
}

export { API_BASE_URL }
