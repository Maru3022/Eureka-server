<#import "/spring.ftl" as spring />
<header class="site-header">
  <div class="shell">
    <nav class="topbar" aria-label="Primary">
      <a class="brand" href="<@spring.url dashboardPath/>">
        <span class="brand-mark">E</span>
        <span class="brand-copy">
          <strong>Eureka Control Center</strong>
          <small>Fitness Platform Discovery</small>
        </span>
      </a>

      <div class="topbar-links">
        <a href="<@spring.url dashboardPath/>">Overview</a>
        <a href="<@spring.url dashboardPath/>/lastn">Lease Events</a>
      </div>
    </nav>
  </div>
</header>
