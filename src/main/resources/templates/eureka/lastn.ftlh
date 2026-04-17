<#import "/spring.ftl" as spring />
<!doctype html>
<html lang="en">
  <head>
    <base href="<@spring.url basePath/>">
    <meta charset="utf-8">
    <title>Eureka Control Center - Lease Events</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
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
      <section class="hero-panel compact">
        <div class="hero-copy">
          <p class="eyebrow">Lease Timeline</p>
          <h1>Recent registry events since server startup.</h1>
          <p class="hero-text">
            Review the latest registration and cancellation activity to spot churn, flapping services, or startup waves across the platform.
          </p>
        </div>
      </section>

      <section class="info-grid">
        <article class="panel">
          <div class="section-heading">
            <div>
              <p class="section-kicker">New Activity</p>
              <h2>Last 1000 registered leases</h2>
            </div>
          </div>
          <div class="table-wrap">
            <table class="registry-table">
              <thead>
                <tr>
                  <th>Timestamp</th>
                  <th>Lease</th>
                </tr>
              </thead>
              <tbody>
                <#if lastNRegistered?has_content>
                  <#list lastNRegistered as entry>
                    <tr>
                      <td>${entry.date?datetime}</td>
                      <td>${entry.id}</td>
                    </tr>
                  </#list>
                <#else>
                  <tr>
                    <td colspan="2" class="empty-state">No registration events are available.</td>
                  </tr>
                </#if>
              </tbody>
            </table>
          </div>
        </article>

        <article class="panel">
          <div class="section-heading">
            <div>
              <p class="section-kicker">Removed Activity</p>
              <h2>Last 1000 cancelled leases</h2>
            </div>
          </div>
          <div class="table-wrap">
            <table class="registry-table">
              <thead>
                <tr>
                  <th>Timestamp</th>
                  <th>Lease</th>
                </tr>
              </thead>
              <tbody>
                <#if lastNCanceled?has_content>
                  <#list lastNCanceled as entry>
                    <tr>
                      <td>${entry.date?datetime}</td>
                      <td>${entry.id}</td>
                    </tr>
                  </#list>
                <#else>
                  <tr>
                    <td colspan="2" class="empty-state">No cancellation events are available.</td>
                  </tr>
                </#if>
              </tbody>
            </table>
          </div>
        </article>
      </section>
    </main>

    <script type="text/javascript" src="eureka/js/wro.js"></script>
  </body>
</html>
