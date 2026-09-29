import "@testing-library/jest-dom/vitest";

class ResizeObserverMock {
  observe() {}
  unobserve() {}
  disconnect() {}
}

// jsdom has no ResizeObserver; MUI's DataGrid needs one to measure its viewport and render rows.
// @ts-expect-error - test-environment polyfill, not a real ResizeObserver
global.ResizeObserver = ResizeObserverMock;

Object.defineProperty(HTMLElement.prototype, "offsetHeight", { configurable: true, value: 600 });
Object.defineProperty(HTMLElement.prototype, "offsetWidth", { configurable: true, value: 800 });
