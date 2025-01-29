// testUtils.js
import {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} from '@firebase/rules-unit-testing';
import { getFirestore, doc, setDoc, getDoc } from 'firebase/firestore';

let testEnv;

export const setupTestEnvironment = async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'demo-project',
    firestore: {
      host: 'localhost',
      port: 8090,
    },
    auth: {
      host: 'localhost',
      port: 9099,
    },
  });
};

export const getTestFirestore = (auth = null) => {
  return testEnv.authenticatedContext(auth?.uid || 'anonymous', auth).firestore();
};

export const cleanupFirestore = async () => {
  await testEnv.clearFirestore();
};

export const tearDown = async () => {
  await testEnv.cleanup();
};

// Exemple de test
// tasks.test.js
import { 
  setupTestEnvironment, 
  getTestFirestore, 
  cleanupFirestore, 
  tearDown 
} from './testUtils';
import { addTask, getTasks } from '../src/services/taskService';

describe('Task Service Tests', () => {
  beforeAll(async () => {
    await setupTestEnvironment();
  });

  afterEach(async () => {
    await cleanupFirestore();
  });

  afterAll(async () => {
    await tearDown();
  });

  it('should add a new task', async () => {
    const db = getTestFirestore({ uid: 'user123' });
    const task = {
      title: 'Test Task',
      completed: false,
      userId: 'user123'
    };

    await addTask(db, task);
    const tasks = await getTasks(db, 'user123');
    
    expect(tasks).toHaveLength(1);
    expect(tasks[0].title).toBe('Test Task');
  });

  it('should not allow unauthorized access', async () => {
    const db = getTestFirestore(); // anonymous user
    const task = {
      title: 'Test Task',
      completed: false,
      userId: 'user123'
    };

    await expect(addTask(db, task)).rejects.toThrow();
  });
});

// Pour les tests d'interface (e2e)
// tasks.e2e.test.js
import { 
  setupTestEnvironment, 
  getTestFirestore, 
  cleanupFirestore, 
  tearDown 
} from './testUtils';
import { render, screen, fireEvent } from '@testing-library/react';
import TaskList from '../src/components/TaskList';

describe('TaskList E2E Tests', () => {
  beforeAll(async () => {
    await setupTestEnvironment();
  });

  afterEach(async () => {
    await cleanupFirestore();
  });

  afterAll(async () => {
    await tearDown();
  });

  it('should display tasks and allow adding new ones', async () => {
    const db = getTestFirestore({ uid: 'user123' });
    
    render(<TaskList db={db} userId="user123" />);
    
    // Ajouter une nouvelle tâche
    const input = screen.getByPlaceholderText('New task');
    fireEvent.change(input, { target: { value: 'New Test Task' } });
    fireEvent.click(screen.getByText('Add'));
    
    // Vérifier que la tâche est affichée
    expect(await screen.findByText('New Test Task')).toBeInTheDocument();
    
    // Vérifier dans Firestore
    const tasks = await getTasks(db, 'user123');
    expect(tasks).toHaveLength(1);
    expect(tasks[0].title).toBe('New Test Task');
  });
});
