import { v4 as uuid } from "uuid";

const env = import.meta.env.MODE;
const API_BASE_URL = env === "Development" ? "https://localhost:7130" : "";

export interface Task {
  clientId: string;
  id: number | undefined;
  label: string;
  complete: boolean;
}

export function generateTaskClientId() {
  return uuid();
}

const idMap = new Map<number, string>();
export function mapClientId(task: Task) {
  const hasClientId = task.clientId && task.clientId != "";

  if (!hasClientId && idMap.has(task.id ?? -1)) {
    task.clientId = idMap.get(task.id ?? -1) ?? "";
    return task;
  }

  if (!hasClientId) {
    task.clientId = generateTaskClientId();
  }

  if (task.id) {
    idMap.set(task.id, task.clientId);
  }

  return task;
}

export const fetchTasks = async (): Promise<Task[]> => {
  const response = await fetch(`${API_BASE_URL}/api/Tasks`);
  if (!response.ok) throw new Error("Failed to fetch tasks");
  return response.json();
};

export const createTask = async (
  task_label: Omit<string, "id">,
): Promise<Task> => {
  const response = await fetch(`${API_BASE_URL}/api/Tasks`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ label: task_label }),
  });
  if (!response.ok) throw new Error("Failed to create task");
  return response.json();
};

export const updateTask = async (task: Task): Promise<Task> => {
  const response = await fetch(`${API_BASE_URL}/api/Tasks/${task.id}`, {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(task),
  });
  if (!response.ok) throw new Error("Failed to update task");
  return response.json();
};

export const deleteTask = async (id: number): Promise<void> => {
  const response = await fetch(`${API_BASE_URL}/api/Tasks/${id}`, {
    method: "DELETE",
  });
  if (!response.ok) throw new Error("Failed to delete task");
};
