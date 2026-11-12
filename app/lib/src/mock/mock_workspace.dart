import '../audit/audit_sink.dart';
import '../workspace/models.dart';
import '../workspace/workspace_state.dart';

// MOCK: the reference design's mock data (Code/reference/Main.dc.html and the
// section reference files). Replaced section by section: databases (WO-5),
// connections (WO-6), conversation and steps (WO-3/4), grade (WO-7).

DateTime _at(int h, int m, int s) => DateTime(2026, 11, 10, h, m, s);

const _noHash = 'MOCK-not-hashed';

const _databases = [
  DatabaseEntry(
    name: 'laws.db',
    path: 'MOCK/laws',
    rank: 1,
    weight: 1.0,
    active: true,
    external: false,
    sha256: _noHash,
    rubric: Rubric(2, 2, 2, 2, 1),
  ),
  DatabaseEntry(
    name: 'principles.db',
    path: 'MOCK/principles',
    rank: 2,
    weight: 0.8,
    active: true,
    external: false,
    sha256: _noHash,
    rubric: Rubric(2, 2, 1, 2, 1),
  ),
  DatabaseEntry(
    name: 'practices.db',
    path: 'MOCK/practices',
    rank: 3,
    weight: 0.6,
    active: true,
    external: false,
    sha256: _noHash,
    rubric: Rubric(2, 1, 1, 2, 1),
  ),
  DatabaseEntry(
    name: 'tools.db',
    path: 'MOCK/tools',
    rank: 4,
    weight: 0.4,
    active: true,
    external: false,
    sha256: _noHash,
    rubric: Rubric(1, 1, 1, 2, 1),
  ),
  DatabaseEntry(
    name: 'external.db',
    path: 'MOCK/external',
    rank: 5,
    weight: 0.2,
    active: false,
    external: true,
    sha256: _noHash,
  ),
];

const _connections = [
  Connection(
    id: 'l1',
    name: 'Local model runtime',
    destination: '127.0.0.1:11434',
    tier: ConnectionTier.local,
  ),
  Connection(
    id: 'l2',
    name: 'Retriever',
    destination: 'loopback',
    tier: ConnectionTier.local,
  ),
  Connection(
    id: 'l3',
    name: 'Folder watcher · laws',
    destination: 'local process',
    tier: ConnectionTier.local,
  ),
  Connection(
    id: 'l4',
    name: 'Folder watcher · practices',
    destination: 'local process',
    tier: ConnectionTier.local,
  ),
  Connection(
    id: 'h1',
    name: 'Frontier API',
    destination: '[provider endpoint]',
    tier: ConnectionTier.hybrid,
    details: [
      'Allowed by you · 2026-11-10 09:12',
      'Idle since 10:43:05',
      'Answers stored as data only',
    ],
  ),
  Connection(
    id: 'h2',
    name: 'Package mirror',
    destination: '[package registry]',
    tier: ConnectionTier.hybrid,
    details: [
      'Allowed for pinned installs',
      'Idle · last used 2026-11-09',
      'Hash-checked downloads',
    ],
  ),
  Connection(
    id: 'e1',
    name: 'Frontier API session',
    destination: '[provider endpoint]',
    tier: ConnectionTier.exposed,
    details: [
      'Process: retriever-bridge',
      'Sent: question only · 412 tokens',
      'Received: 1 answer → external.db (rank 5)',
      'Approved by you · 10:43:01',
      'Encrypted (TLS)',
    ],
  ),
];

const _conversation = [
  Turn(
    question: 'What do our sources require before personal data is stored in a local database?',
    model: 'Olmo-3-7B-Instruct',
    answer: [
      Sentence(
        text: 'Store only the fields the task needs, and record why each one is kept.',
        citation: ContextFile(database: 'laws', chunkId: '1182', weight: 1.0),
        sourceExcerpt:
            'MOCK · laws.db chunk 1182: personal data shall be adequate, relevant and limited '
            'to what is necessary, and the purpose of each field recorded.',
      ),
      Sentence(
        text: 'Encrypt the database file at rest and keep the key off the machine.',
        citation: ContextFile(
          database: 'principles',
          chunkId: '0417',
          weight: 0.8,
        ),
        sourceExcerpt:
            'MOCK · principles.db chunk 0417: data at rest is encrypted; keys are held '
            'separately from the data they protect.',
      ),
      Sentence(
        text: 'Log every read of a personal record to the local audit table.',
        citation: ContextFile(
          database: 'practices',
          chunkId: '2290',
          weight: 0.6,
        ),
        samples: SampleCheck(disagreed: 2, of: 5),
        sourceExcerpt: 'MOCK · practices.db chunk 2290: access to personal records is logged locally.',
      ),
    ],
  ),
];

const _contextFiles = [
  ContextFile(database: 'laws', chunkId: '1182', weight: 1.0),
  ContextFile(database: 'principles', chunkId: '0417', weight: 0.8),
  ContextFile(database: 'principles', chunkId: '0419', weight: 0.8),
  ContextFile(database: 'practices', chunkId: '2290', weight: 0.6),
  ContextFile(database: 'practices', chunkId: '2291', weight: 0.6),
  ContextFile(database: 'tools', chunkId: '0093', weight: 0.4),
  ContextFile.oneOff('scope-memo.pdf'),
];

const _steps = [
  TaskStage(name: 'Select databases', state: StepState.done),
  TaskStage(name: 'Retrieve and rank', state: StepState.done),
  TaskStage(name: 'Gate check', state: StepState.done),
  TaskStage(name: 'Draft answer', state: StepState.current),
  TaskStage(name: 'Human review', state: StepState.waiting),
];

const _tasks = [
  TaskStage(
    name: 'Engineering',
    state: StepState.done,
    note: 'Requirements set · done',
  ),
  TaskStage(
    name: 'Code',
    state: StepState.current,
    note: 'In progress · step 4 of 5',
    step: 4,
    stepsTotal: 5,
  ),
  TaskStage(
    name: 'Tech data',
    state: StepState.waiting,
    note: 'Waiting on review',
  ),
];

const _grade = GradeSnapshot(
  total: 8.1,
  changeSinceMilestone: 0.3,
  components: [
    ('Source quality (weighted rubric)', '8.4'),
    ('Claims with a source', '12 / 12'),
    ('Sample agreement', '11 / 12'),
    ('Gate calls passed', '41 / 42'),
    ('External data share', '6%'),
  ],
  needsHuman: ['1 rejected gate call', '1 claim with split samples'],
);

List<AuditEntry> _audit() => [
  AuditEntry(
    time: _at(10, 43, 5),
    kind: 'external_stored',
    summary: 'External answer stored as data · rank 5',
    needsHuman: false,
    detail: 'external.db · stored as data, never as instructions',
  ),
  AuditEntry(
    time: _at(10, 43, 2),
    kind: 'left_machine',
    summary: 'Left machine · question only · 412 tokens · frontier API',
    needsHuman: true,
    detail: 'Approved by you at 10:43:01 · encrypted (TLS)',
  ),
  AuditEntry(
    time: _at(10, 42, 31),
    kind: 'gate_reject',
    summary: 'Gate rejected · write_file outside allowlist',
    needsHuman: true,
    detail: 'Proposed action write_file is not on the allowlist (search, get_source).',
  ),
  AuditEntry(
    time: _at(10, 42, 19),
    kind: 'retrieval',
    summary: 'Retrieved 6 chunks from 3 databases',
    needsHuman: false,
  ),
  AuditEntry(
    time: _at(10, 42, 18),
    kind: 'gate_pass',
    summary: 'Gate passed · search(laws.db)',
    needsHuman: false,
  ),
];

/// MOCK starting workspace.
WorkspaceState mockWorkspace() => WorkspaceState(
  databases: _databases,
  connections: _connections,
  conversation: _conversation,
  contextFiles: _contextFiles,
  tokensUsed: 3840,
  tokenWindow: 32768,
  steps: _steps,
  tasks: _tasks,
  grade: _grade,
  audit: List.unmodifiable(_audit()),
);
