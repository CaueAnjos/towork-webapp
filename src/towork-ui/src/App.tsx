import React, { useState } from "react";
import {
  QueryClient,
  QueryClientProvider,
  useQuery,
  useMutation,
  useQueryClient,
} from "@tanstack/react-query";
import { Plus, Check, Trash2, Edit2, X, Loader2 } from "lucide-react";
import {
  fetchTasks,
  updateTask,
  createTask,
  deleteTask,
  mapClientId,
} from "./ToworkApi.ts";
import type { Task } from "./ToworkApi.ts";

// Task Item Component
const TaskItem: React.FC<{ task: Task }> = ({ task }) => {
  const queryClient = useQueryClient();
  const [isEditing, setIsEditing] = useState(false);
  const [editLabel, setEditLabel] = useState(task.label);

  const updateMutation = useMutation({
    mutationFn: updateTask,
    onMutate: async (task: Task, context) => {
      await context.client.cancelQueries({ queryKey: ["tasks"] });
      const previousTasks = context.client.getQueryData(["tasks"]);

      context.client.setQueryData(["tasks"], (old: Task[]) =>
        old.map((e) => {
          if (e.clientId == task.clientId) {
            return task;
          }
          return e;
        }),
      );

      setIsEditing(false);

      return { previousTasks };
    },
    onError: (_err, task, onMutationResult, context) => {
      setIsEditing(true);
      setEditLabel(task.label);
      context.client.setQueryData(["tasks"], onMutationResult?.previousTasks);
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ["tasks"] });
    },
  });

  const deleteMutation = useMutation({
    mutationFn: deleteTask,
    onMutate: async (deletedId: number, context) => {
      await context.client.cancelQueries({ queryKey: ["tasks"] });
      const previousTasks = context.client.getQueryData(["tasks"]);
      context.client.setQueryData(["tasks"], (old: Task[]) =>
        old.filter((t) => t.id != deletedId),
      );
      return { previousTasks };
    },
    onError: (_err, _deletedId, onMutateResult, context) => {
      context.client.setQueryData(["tasks"], onMutateResult?.previousTasks);
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ["tasks"] });
    },
  });

  const handleToggleComplete = () => {
    updateMutation.mutate({ ...task, complete: !task.complete });
  };

  const handleUpdate = () => {
    updateMutation.mutate({
      ...task,
      label: editLabel,
    });
  };

  if (isEditing) {
    return (
      <div className="bg-white rounded-xl p-6 shadow-lg border border-blue-100 animate-fadeIn">
        <input
          type="text"
          value={editLabel}
          onChange={(e) => setEditLabel(e.target.value)}
          className="w-full mb-3 px-4 py-2 border-2 border-blue-200 rounded-lg focus:border-blue-500 focus:outline-none transition-colors"
          placeholder="Task title"
        />
        <div className="flex gap-2">
          <button
            onClick={handleUpdate}
            disabled={updateMutation.isPending}
            className="flex-1 bg-gradient-to-r from-blue-500 to-purple-500 text-white px-4 py-2 rounded-lg hover:from-blue-600 hover:to-purple-600 transition-all disabled:opacity-50 flex items-center justify-center gap-2"
          >
            {updateMutation.isPending ? (
              <Loader2 className="w-4 h-4 animate-spin" />
            ) : (
              <Check className="w-4 h-4" />
            )}
            Save
          </button>
          <button
            onClick={() => setIsEditing(false)}
            className="px-4 py-2 border-2 border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
          >
            <X className="w-4 h-4" />
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-xl p-6 shadow-lg border border-blue-100 hover:shadow-xl transition-all duration-300 animate-fadeIn">
      <div className="flex items-start gap-4">
        <button
          onClick={handleToggleComplete}
          className={`mt-1 w-6 h-6 rounded-full border-2 flex items-center justify-center transition-all ${
            task.complete
              ? "bg-gradient-to-r from-blue-500 to-purple-500 border-blue-500"
              : "border-gray-300 hover:border-blue-400"
          }`}
        >
          {task.complete && <Check className="w-4 h-4 text-white" />}
        </button>
        <div className="flex-1">
          <h3
            className={`text-lg font-semibold mb-1 ${task.complete ? "line-through text-gray-400" : "text-gray-800"}`}
          >
            {task.label}
          </h3>
          <p
            className={`text-sm ${task.complete ? "text-gray-300" : "text-gray-600"}`}
          ></p>
        </div>
        <div className="flex gap-2">
          <button
            onClick={() => setIsEditing(true)}
            className="p-2 hover:bg-blue-50 rounded-lg transition-colors text-blue-600"
          >
            <Edit2 className="w-4 h-4" />
          </button>
          <button
            onClick={() => deleteMutation.mutate(task.id ?? 0)}
            className="p-2 hover:bg-red-50 rounded-lg transition-colors text-red-600 disabled:opacity-50"
          >
            <Trash2 className="w-4 h-4" />
          </button>
        </div>
      </div>
    </div>
  );
};

// Add Task Form Component
const AddTaskForm: React.FC = () => {
  const queryClient = useQueryClient();
  const [title, setTitle] = useState("");

  const createMutation = useMutation({
    mutationFn: createTask,
    onMutate: async (label: string, context) => {
      await context.client.cancelQueries({ queryKey: ["tasks"] });
      const previousTasks = context.client.getQueryData<Task[]>(["tasks"]);

      let task: Task = {
        clientId: "",
        id: undefined,
        label: label,
        complete: false,
      };
      mapClientId(task);

      context.client.setQueryData(["tasks"], (old: Task[]) => [...old, task]);
      setTitle("");

      return { previousTasks, clientId: task.clientId };
    },
    onError: (_err, label, onMutateResult, context) => {
      context.client.setQueryData(["tasks"], onMutateResult?.previousTasks);
      setTitle(label);
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ["tasks"] });
    },
    onSuccess: (data, _label, onMutateResult, _context) => {
      let newData = data;
      newData.clientId = onMutateResult.clientId;
      mapClientId(newData);
    },
  });

  const handleSubmit = () => {
    if (title.trim()) {
      createMutation.mutate(title.trim());
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      handleSubmit();
    }
  };

  return (
    <div className="bg-white rounded-xl p-6 shadow-lg border-2 border-blue-200">
      <div className="flex gap-3">
        <input
          type="text"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          onKeyDown={handleKeyDown}
          placeholder="Add a new task..."
          className="flex-1 px-4 py-3 border-2 border-blue-200 rounded-lg focus:border-blue-500 focus:outline-none transition-colors"
        />
        <button
          onClick={handleSubmit}
          disabled={!title.trim()}
          className="bg-gradient-to-r from-blue-500 to-purple-500 text-white px-6 py-3 rounded-lg hover:from-blue-600 hover:to-purple-600 transition-all disabled:opacity-50 flex items-center gap-2 font-semibold"
        >
          {createMutation.isPending ? (
            <Loader2 className="w-5 h-5 animate-spin" />
          ) : (
            <Plus className="w-5 h-5" />
          )}
          Add
        </button>
      </div>
    </div>
  );
};

// Main App Component
const TaskManager: React.FC = () => {
  const {
    data: tasks,
    isLoading,
    error,
  } = useQuery({
    queryKey: ["tasks"],
    queryFn: fetchTasks,
    select: (data) => data.map((e) => mapClientId(e)),
  });

  const activeTasks = tasks?.filter((t) => (t ? !t.complete : true)) || [];
  const completedTasks = tasks?.filter((t) => (t ? t.complete : false)) || [];

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-purple-50 to-blue-50 py-12 px-4">
      <div className="max-w-4xl mx-auto">
        <div className="text-center mb-12">
          <h1 className="text-5xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent mb-3">
            Towork-Webapp
          </h1>
          <p className="text-gray-600 text-lg">
            Organize your life, one task at a time
          </p>
        </div>

        <div className="mb-8">
          <AddTaskForm />
        </div>

        {error && (
          <div className="bg-red-50 border-2 border-red-200 rounded-xl p-4 mb-6 text-red-700">
            Error loading tasks. Please check your API connection.
          </div>
        )}

        {isLoading ? (
          <div className="flex items-center justify-center py-20">
            <Loader2 className="w-12 h-12 animate-spin text-blue-500" />
          </div>
        ) : (
          <>
            {activeTasks.length > 0 && (
              <div className="mb-8">
                <h2 className="text-2xl font-bold text-gray-800 mb-4 flex items-center gap-2">
                  Active Tasks
                  <span className="bg-blue-500 text-white text-sm px-3 py-1 rounded-full">
                    {activeTasks.length}
                  </span>
                </h2>
                <div className="space-y-4">
                  {activeTasks.map((task) => (
                    <TaskItem key={task.clientId} task={task} />
                  ))}
                </div>
              </div>
            )}

            {completedTasks.length > 0 && (
              <div>
                <h2 className="text-2xl font-bold text-gray-800 mb-4 flex items-center gap-2">
                  Completed
                  <span className="bg-green-500 text-white text-sm px-3 py-1 rounded-full">
                    {completedTasks.length}
                  </span>
                </h2>
                <div className="space-y-4">
                  {completedTasks.map((task) => (
                    <TaskItem key={task.clientId} task={task} />
                  ))}
                </div>
              </div>
            )}

            {tasks?.length === 0 && (
              <div className="text-center py-20">
                <div className="bg-white rounded-full w-24 h-24 flex items-center justify-center mx-auto mb-4 shadow-lg">
                  <Check className="w-12 h-12 text-blue-500" />
                </div>
                <h3 className="text-2xl font-bold text-gray-700 mb-2">
                  No tasks yet
                </h3>
                <p className="text-gray-500">
                  Create your first task to get started!
                </p>
              </div>
            )}
          </>
        )}
      </div>

      <style>{`
        @keyframes fadeIn {
          from {
            opacity: 0;
            transform: translateY(-10px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }
        .animate-fadeIn {
          animation: fadeIn 0.3s ease-out;
        }
      `}</style>
    </div>
  );
};

// Query Client Setup
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
      retry: 1,
    },
  },
});

// Root Component
export default function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <TaskManager />
    </QueryClientProvider>
  );
}
