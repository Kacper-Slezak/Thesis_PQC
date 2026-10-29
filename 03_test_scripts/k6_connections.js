// Holds about CONNS connections open at the same time through the sidecars.
// Every VU sends one request at a time to /delay/DELAY, so CONNS requests are always
// in flight and the client sidecar needs CONNS upstream (mTLS) connections.
// Offered load is only CONNS / DELAY requests per second (e.g. 400 / 5 s = 80 req/s).
import http from 'k6/http';
import { check } from 'k6';

const CONNS = Number(__ENV.CONNS || 100);
const DELAY = Number(__ENV.DELAY || 5);
const RAMP = __ENV.RAMP || '20s';
const HOLD = __ENV.HOLD || '70s';
const TARGET = __ENV.TARGET_URL || `http://httpbin.default.svc.cluster.local:8000/delay/${DELAY}`;

export const options = {
  scenarios: {
    hold: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [{ duration: RAMP, target: CONNS }, { duration: HOLD, target: CONNS }],
      gracefulRampDown: '0s',
      gracefulStop: `${DELAY + 2}s`,
    },
  },
  discardResponseBodies: true,
  summaryTrendStats: ['med', 'p(99)', 'max'],
};

export default function () {
  const res = http.get(TARGET, { timeout: `${DELAY + 30}s` });
  check(res, { 'status is 200': (r) => r.status === 200 });
}

export function handleSummary(data) {
  return { '/tmp/summary_mem.json': JSON.stringify(data, null, 2) };
}
