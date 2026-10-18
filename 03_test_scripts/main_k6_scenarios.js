import http from 'k6/http';
import { check } from 'k6';

const TARGET = __ENV.TARGET_URL || 'http://httpbin.default.svc.cluster.local:8000/get';
const TEST_TYPE = __ENV.TEST_TYPE || 'handshake';
const RATE = Number(__ENV.RATE || 200);
const DURATION = __ENV.DURATION || '60s';
const VUS = Number(__ENV.VUS || 100);
const PREALLOC_VUS = Number(__ENV.PREALLOC_VUS || 200);
const MAX_VUS = Number(__ENV.MAX_VUS || 800);

function scenario() {
  if (TEST_TYPE === 'max') {
    return { executor: 'constant-vus', vus: VUS, duration: DURATION };
  }
  return {
    executor: 'constant-arrival-rate',
    rate: RATE,
    timeUnit: '1s',
    duration: DURATION,
    preAllocatedVUs: PREALLOC_VUS,
    maxVUs: MAX_VUS,
  };
}

export const options = {
  scenarios: { main: scenario() },
  discardResponseBodies: true,
  summaryTrendStats: ['avg', 'min', 'med', 'p(90)', 'p(95)', 'p(99)', 'max'],
};

export default function () {
  const res = http.get(TARGET);
  check(res, { 'status is 200': (r) => r.status === 200 });
}


export function handleSummary(data) {
  return { '/tmp/summary.json': JSON.stringify(data, null, 2) };
}