<#import "/spring.ftl" as spring />
<#assign totalInstances = 0>
<#assign downInstances = 0>
<#if apps?has_content>
  <#list apps as app>
    <#list app.instanceInfos as group>
      <#assign totalInstances = totalInstances + group.instances?size>
      <#if group.isNotUp>
        <#assign downInstances = downInstances + group.instances?size>
      </#if>
    </#list>
  </#list>
</#if>
<!doctype html>
<html lang="en">
  <head>
    <base href="<@spring.url basePath/>">
    <meta charset="utf-8">
    <title>Eureka Control Center</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="Custom Eureka dashboard for service discovery and registry observability.">
    <link rel="stylesheet" href="eureka/css/wro.css">
  </head>
  <body class="dashboard-body">
    <script type="text/javascript">
      if (document.documentMode) {
        document.write('<p class="legacy-browser">You are using an outdated browser. Please upgrade for the best experience.</p>');
      }
    </script>

    <#include "header.ftlh">

    <main class="shell dashboard-main">
      <section class="hero-panel">
        <div class="hero-copy">
          <p class="eyebrow">Service Discovery Registry</p>
          <h1>Beautifully clearer visibility into your microservice network.</h1>
          <p class="hero-text">
            Monitor service registration, renewal health, registry state, and node details from a cleaner Eureka dashboard tuned for this platform.
          </p>
        </div>

        <div class="hero-stats">
          <article class="metric-card">
            <span class="metric-label">Applications</span>
            <strong class="metric-value">${apps?size}</strong>
            <span class="metric-note">registered groups</span>
          </article>
          <article class="metric-card">
            <span class="metric-label">Instances</span>
            <strong class="metric-value">${totalInstances}</strong>
            <span class="metric-note">active rows in registry</span>
          </article>
          <article class="metric-card">
            <span class="metric-label">Attention Needed</span>
            <strong class="metric-value">${downInstances}</strong>
            <span class="metric-note">instances not currently UP</span>
          </article>
          <article class="metric-card">
            <span class="metric-label">Replicas</span>
            <strong class="metric-value">${replicas?size}</strong>
            <span class="metric-note">peer registry nodes</span>
          </article>
        </div>
      </section>

      <#if isBelowRenewThreshold>
        <section class="alert-banner danger">
          <strong>Renewals are below threshold.</strong>
          <span>
            <#if registry.selfPreservationModeEnabled>
              Self-preservation is enabled, so Eureka is keeping instances longer to avoid false expiry during network instability.
            <#else>
              Self-preservation is disabled, so instance expiry may be more aggressive during outages or network turbulence.
            </#if>
          </span>
        </section>
      <#elseif !registry.selfPreservationModeEnabled>
        <section class="alert-banner caution">
          <strong>Self-preservation is disabled.</strong>
          <span>This is convenient for local development, but it is less protective under partial network failure.</span>
        </section>
      </#if>

      <section class="panel">
        <div class="section-heading">
          <div>
            <p class="section-kicker">Registry Overview</p>
            <h2>Applications currently registered with Eureka</h2>
          </div>
        </div>

        <div class="table-wrap">
          <table class="registry-table">
            <thead>
              <tr>
                <th>Application</th>
                <th>AMIs</th>
                <th>Availability Zones</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              <#if apps?has_content>
                <#list apps as app>
                  <tr>
                    <td>
                      <div class="app-cell">
                        <strong>${app.name}</strong>
                      </div>
                    </td>
                    <td>
                      <#if app.amiCounts?has_content>
                        <#list app.amiCounts as amiCount>
                          <span class="pill">${amiCount.key}: ${amiCount.value}</span>
                        </#list>
                      <#else>
                        <span class="muted">None</span>
                      </#if>
                    </td>
                    <td>
                      <#if app.zoneCounts?has_content>
                        <#list app.zoneCounts as zoneCount>
                          <span class="pill">${zoneCount.key}: ${zoneCount.value}</span>
                        </#list>
                      <#else>
                        <span class="muted">Default</span>
                      </#if>
                    </td>
                    <td>
                      <div class="status-stack">
                        <#list app.instanceInfos as group>
                          <div class="status-group">
                            <span class="status-badge <#if group.isNotUp>status-bad<#else>status-good</#if>">${group.status}</span>
                            <span class="muted">${group.instances?size} instance(s)</span>
                            <div class="instance-links">
                              <#list group.instances as instance>
                                <#if instance.isHref>
                                  <a href="${instance.url}" target="_blank" rel="noreferrer">${instance.id}</a>
                                <#else>
                                  <span>${instance.id}</span>
                                </#if>
                              </#list>
                            </div>
                          </div>
                        </#list>
                      </div>
                    </td>
                  </tr>
                </#list>
              <#else>
                <tr>
                  <td colspan="4" class="empty-state">No instances are currently registered.</td>
                </tr>
              </#if>
            </tbody>
          </table>
        </div>
      </section>

      <section class="info-grid">
        <article class="panel">
          <div class="section-heading">
            <div>
              <p class="section-kicker">System</p>
              <h2>Server status</h2>
            </div>
          </div>
          <div class="detail-grid">
            <div class="detail-item">
              <span>Environment</span>
              <strong>${environment!}</strong>
            </div>
            <div class="detail-item">
              <span>Data center</span>
              <strong>${datacenter!}</strong>
            </div>
            <div class="detail-item">
              <span>Current time</span>
              <strong>${currentTime}</strong>
            </div>
            <div class="detail-item">
              <span>Uptime</span>
              <strong>${upTime}</strong>
            </div>
            <div class="detail-item">
              <span>Lease expiration</span>
              <strong>${registry.leaseExpirationEnabled?c}</strong>
            </div>
            <div class="detail-item">
              <span>Renews threshold</span>
              <strong>${registry.numOfRenewsPerMinThreshold}</strong>
            </div>
            <div class="detail-item">
              <span>Renews last minute</span>
              <strong>${registry.numOfRenewsInLastMin}</strong>
            </div>
            <#if amazonInfo??>
              <div class="detail-item">
                <span>AMI</span>
                <strong>${amiId!}</strong>
              </div>
              <div class="detail-item">
                <span>Zone</span>
                <strong>${availabilityZone!}</strong>
              </div>
              <div class="detail-item">
                <span>Instance ID</span>
                <strong>${instanceId!}</strong>
              </div>
            </#if>
          </div>
        </article>

        <article class="panel">
          <div class="section-heading">
            <div>
              <p class="section-kicker">Replication</p>
              <h2>Peer replicas</h2>
            </div>
          </div>
          <#if replicas?has_content>
            <div class="replica-list">
              <#list replicas as replica>
                <a class="replica-item" href="${replica.value}">${replica.key}</a>
              </#list>
            </div>
          <#else>
            <p class="empty-copy">No replica peers are configured for the current runtime profile.</p>
          </#if>
        </article>
      </section>

      <section class="info-grid">
        <article class="panel">
          <div class="section-heading">
            <div>
              <p class="section-kicker">Telemetry</p>
              <h2>General info</h2>
            </div>
          </div>
          <div class="kv-list">
            <#list statusInfo.generalStats?keys as stat>
              <div class="kv-row">
                <span>${stat}</span>
                <strong>${statusInfo.generalStats[stat]!""}</strong>
              </div>
            </#list>
            <#list statusInfo.applicationStats?keys as stat>
              <div class="kv-row">
                <span>${stat}</span>
                <strong>${statusInfo.applicationStats[stat]!""}</strong>
              </div>
            </#list>
          </div>
        </article>

        <article class="panel">
          <div class="section-heading">
            <div>
              <p class="section-kicker">Node</p>
              <h2>Instance info</h2>
            </div>
          </div>
          <div class="kv-list">
            <#list instanceInfo?keys as key>
              <div class="kv-row">
                <span>${key}</span>
                <strong>${instanceInfo[key]!""}</strong>
              </div>
            </#list>
          </div>
        </article>
      </section>
    </main>

    <script type="text/javascript" src="eureka/js/wro.js"></script>
  </body>
</html>
