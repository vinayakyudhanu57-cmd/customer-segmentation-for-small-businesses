/**
 * web/script.js - Customer Insights
 * Clean, minimal, data-driven frontend application
 * Zero external dependencies • Pure vanilla JavaScript
 */

// Application State
let appData = null;
let filteredCustomers = [];
let currentPage = 1;
const pageSize = 15;
let currentMetric = 'avg_annual_income';

// DOM Element References
const statTotalCustomers = document.getElementById('stat-total-customers');
const statAvgIncome = document.getElementById('stat-avg-income');
const statAvgFreq = document.getElementById('stat-avg-freq');
const statAvgAmount = document.getElementById('stat-avg-amount');
const lastUpdatedText = document.getElementById('last-updated-text');
const dataStatusLabel = document.getElementById('data-status-label');
const errorAlert = document.getElementById('error-alert');

const segmentsContainer = document.getElementById('segments-cards-container');
const chartBarsContainer = document.getElementById('chart-bars-container');
const chartToggleButtons = document.querySelectorAll('.btn-toggle');

const customerSearchInput = document.getElementById('customer-search-input');
const clusterFilterSelect = document.getElementById('cluster-filter-select');
const tableRecordCount = document.getElementById('table-record-count');
const tableBody = document.getElementById('customers-table-body');
const btnPrevPage = document.getElementById('btn-prev-page');
const btnNextPage = document.getElementById('btn-next-page');
const pageIndicator = document.getElementById('page-indicator');

const insightsContainer = document.getElementById('insights-container');

/**
 * Format currency in USD
 */
function formatCurrency(val) {
  if (val === undefined || val === null || isNaN(val)) return '$0.00';
  return '$' + Number(val).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

/**
 * Format integers
 */
function formatNumber(val) {
  if (val === undefined || val === null || isNaN(val)) return '0';
  return Number(val).toLocaleString('en-US');
}

/**
 * Fetch dashboard data with fallback path resolution
 */
async function loadDashboardData() {
  const potentialPaths = [
    '../output/dashboard_data.json',
    'output/dashboard_data.json',
    './output/dashboard_data.json'
  ];

  let loaded = false;

  for (const path of potentialPaths) {
    try {
      const response = await fetch(path);
      if (response.ok) {
        appData = await response.json();
        loaded = true;
        dataStatusLabel.textContent = 'Active • 100 Customers';
        break;
      }
    } catch (e) {
      // Continue to next path
    }
  }

  if (!loaded || !appData) {
    // Show user-friendly error guidance
    errorAlert.style.display = 'flex';
    dataStatusLabel.textContent = 'Error Loading Outputs';
    dataStatusLabel.style.color = '#d97706';
    return;
  }

  // Populate UI
  initializeDashboard();
}

/**
 * Initialize all dashboard sections
 */
function initializeDashboard() {
  renderOverview();
  renderSegments();
  renderComparisonChart();
  initializeCustomerExplorer();
  renderMarketingInsights();
}

/**
 * 1. Overview Section
 */
function renderOverview() {
  const ov = appData.overview;
  if (!ov) return;

  statTotalCustomers.textContent = formatNumber(ov.total_customers);
  statAvgIncome.textContent = formatCurrency(ov.avg_annual_income);
  statAvgFreq.textContent = Number(ov.avg_purchase_frequency).toFixed(1) + ' / yr';
  statAvgAmount.textContent = formatCurrency(ov.avg_purchase_amount);

  if (appData.generated_at) {
    lastUpdatedText.textContent = `Analysis: ${appData.generated_at}`;
  }
}

/**
 * 2. Customer Segments Cards
 */
function renderSegments() {
  if (!appData.clusters || !appData.insights) return;

  segmentsContainer.innerHTML = '';

  appData.clusters.forEach((cluster, idx) => {
    const insight = appData.insights.find(ins => ins.cluster === cluster.cluster) || {};
    const clusterId = cluster.cluster;
    const badgeClass = `c${clusterId}`;

    const card = document.createElement('div');
    card.className = 'segment-card';
    card.innerHTML = `
      <div class="segment-header">
        <span class="cluster-badge ${badgeClass}">Cluster ${clusterId}</span>
        <span class="segment-pct">${cluster.percentage}% of total</span>
      </div>
      <h3 class="segment-name">${escapeHTML(insight.segment_name || 'Segment ' + clusterId)}</h3>
      <div class="segment-population">${formatNumber(cluster.customer_count)} assigned customers</div>
      
      <div class="segment-metrics">
        <div class="metric-row">
          <span class="metric-label">Avg. Age</span>
          <span class="metric-val">${cluster.avg_age} yrs</span>
        </div>
        <div class="metric-row">
          <span class="metric-label">Avg. Income</span>
          <span class="metric-val">${formatCurrency(cluster.avg_annual_income)}</span>
        </div>
        <div class="metric-row">
          <span class="metric-label">Purchase Frequency</span>
          <span class="metric-val">${cluster.avg_purchase_frequency} visits/yr</span>
        </div>
        <div class="metric-row">
          <span class="metric-label">Avg. Basket Amount</span>
          <span class="metric-val">${formatCurrency(cluster.avg_purchase_amount)}</span>
        </div>
        <div class="metric-row">
          <span class="metric-label">Est. Annual Value</span>
          <span class="metric-val">${formatCurrency(cluster.est_annual_spend_per_customer)}</span>
        </div>
      </div>

      <div class="segment-strategy-preview">
        <strong>Strategy:</strong> ${escapeHTML(insight.recommended_strategy || 'Targeted segment optimization.')}
      </div>
    `;

    segmentsContainer.appendChild(card);
  });
}

/**
 * Segment Comparison Chart (Clean, minimal horizontal SVG/CSS bars)
 */
function renderComparisonChart() {
  if (!appData.clusters) return;

  chartBarsContainer.innerHTML = '';

  const metricConfig = {
    avg_annual_income: { label: 'Avg. Income', prefix: '$', decimals: 2 },
    avg_purchase_frequency: { label: 'Visits / Yr', prefix: '', decimals: 1 },
    avg_purchase_amount: { label: 'Avg. Basket', prefix: '$', decimals: 2 },
    est_annual_spend_per_customer: { label: 'Annual Spend', prefix: '$', decimals: 2 }
  };

  const currentConf = metricConfig[currentMetric] || { prefix: '', decimals: 1 };

  // Determine max value for 100% bar scaling
  const maxVal = Math.max(...appData.clusters.map(c => Number(c[currentMetric]) || 0));

  appData.clusters.forEach(cluster => {
    const clusterId = cluster.cluster;
    const insight = appData.insights.find(ins => ins.cluster === clusterId) || {};
    const val = Number(cluster[currentMetric]) || 0;
    const pctWidth = maxVal > 0 ? (val / maxVal) * 100 : 0;

    let displayVal = currentConf.prefix === '$' ? formatCurrency(val) : val.toFixed(currentConf.decimals);

    const row = document.createElement('div');
    row.className = 'bar-row';
    row.innerHTML = `
      <div class="bar-label">Cluster ${clusterId}: ${escapeHTML(insight.segment_name || '')}</div>
      <div class="bar-track">
        <div class="bar-fill c${clusterId}" style="width: ${Math.max(4, pctWidth)}%;"></div>
      </div>
      <div class="bar-val-text">${displayVal}</div>
    `;

    chartBarsContainer.appendChild(row);
  });
}

// Chart toggle buttons
chartToggleButtons.forEach(btn => {
  btn.addEventListener('click', () => {
    chartToggleButtons.forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    currentMetric = btn.getAttribute('data-metric');
    renderComparisonChart();
  });
});

/**
 * 3. Customer Explorer Table & Filtering
 */
function initializeCustomerExplorer() {
  if (!appData.customers) return;
  filteredCustomers = [...appData.customers];
  currentPage = 1;
  applyTableFilterAndPagination();

  customerSearchInput.addEventListener('input', () => {
    currentPage = 1;
    filterCustomers();
  });

  clusterFilterSelect.addEventListener('change', () => {
    currentPage = 1;
    filterCustomers();
  });

  btnPrevPage.addEventListener('click', () => {
    if (currentPage > 1) {
      currentPage--;
      renderTablePage();
    }
  });

  btnNextPage.addEventListener('click', () => {
    const totalPages = Math.ceil(filteredCustomers.length / pageSize) || 1;
    if (currentPage < totalPages) {
      currentPage++;
      renderTablePage();
    }
  });
}

function filterCustomers() {
  const searchTerm = customerSearchInput.value.trim().toLowerCase();
  const selectedCluster = clusterFilterSelect.value;

  filteredCustomers = appData.customers.filter(c => {
    // Cluster filter
    if (selectedCluster !== 'all' && String(c.cluster) !== selectedCluster) {
      return false;
    }

    // Search filter
    if (searchTerm) {
      const matchId = String(c.customer_id).toLowerCase().includes(searchTerm);
      const matchAge = String(c.age).includes(searchTerm);
      const matchIncome = String(c.annual_income).includes(searchTerm);
      if (!matchId && !matchAge && !matchIncome) return false;
    }

    return true;
  });

  applyTableFilterAndPagination();
}

function applyTableFilterAndPagination() {
  tableRecordCount.textContent = `Showing ${filteredCustomers.length} of ${appData.customers.length} customers`;
  renderTablePage();
}

function renderTablePage() {
  const totalPages = Math.ceil(filteredCustomers.length / pageSize) || 1;
  if (currentPage > totalPages) currentPage = totalPages;

  pageIndicator.textContent = `Page ${currentPage} of ${totalPages}`;
  btnPrevPage.disabled = (currentPage <= 1);
  btnNextPage.disabled = (currentPage >= totalPages);

  const startIdx = (currentPage - 1) * pageSize;
  const pageItems = filteredCustomers.slice(startIdx, startIdx + pageSize);

  tableBody.innerHTML = '';

  if (pageItems.length === 0) {
    const emptyRow = document.createElement('tr');
    emptyRow.innerHTML = `<td colspan="6" style="text-align: center; color: var(--text-muted); padding: 2rem;">No customers match your criteria.</td>`;
    tableBody.appendChild(emptyRow);
    return;
  }

  pageItems.forEach(c => {
    const row = document.createElement('tr');
    row.innerHTML = `
      <td><strong>#${c.customer_id}</strong></td>
      <td>${c.age}</td>
      <td>${formatCurrency(c.annual_income)}</td>
      <td>${c.purchase_frequency} / yr</td>
      <td>${formatCurrency(c.average_purchase_amount)}</td>
      <td><span class="cluster-badge c${c.cluster}">Cluster ${c.cluster}</span></td>
    `;
    tableBody.appendChild(row);
  });
}

/**
 * 4. Marketing Insights Section
 */
function renderMarketingInsights() {
  if (!appData.insights) return;

  insightsContainer.innerHTML = '';

  appData.insights.forEach(insight => {
    const card = document.createElement('div');
    card.className = 'insight-card';
    card.innerHTML = `
      <div class="insight-header">
        <span class="cluster-badge c${insight.cluster}">Cluster ${insight.cluster}</span>
        <span style="font-size: 0.78rem; color: var(--text-muted); font-weight: 600;">${insight.percentage}% Audience</span>
      </div>
      <h3 class="insight-title">${escapeHTML(insight.segment_name)}</h3>

      <div class="insight-section">
        <div class="insight-label">Key Characteristics</div>
        <p class="insight-text">${escapeHTML(insight.key_characteristics)}</p>
      </div>

      <div class="insight-section">
        <div class="insight-label">Recommended Strategy</div>
        <div class="strategy-box">${escapeHTML(insight.recommended_strategy)}</div>
      </div>

      <div class="insight-section">
        <div class="insight-label">Observed Rationale</div>
        <p class="insight-text">${escapeHTML(insight.rationale)}</p>
      </div>
    `;

    insightsContainer.appendChild(card);
  });
}

function escapeHTML(str) {
  if (!str) return '';
  return String(str).replace(/[&<>'"]/g, tag => ({
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    "'": '&#39;',
    '"': '&quot;'
  }[tag] || tag));
}

// Initialize on DOM Ready
document.addEventListener('DOMContentLoaded', () => {
  loadDashboardData();
});
