# Example SQL queries for web analytics

With Ahoy and [Blazer](https://github.com/ankane/blazer), you can create dashboards for your web analytics. Here are some sample queries to get you started.

## Active Visitors

Count of number of visitors over the last 1 day, 7 days, and 28 days.

```sql
SELECT
    date,
    daily AS "1 day",
    SUM(daily) OVER (order by date rows between 7 preceding and current row) AS "7 day",
    SUM(daily) OVER (order by date rows between 28 preceding and current row) AS "28 day"
FROM (
    SELECT
        date_trunc('day', started_at) date,
        COUNT(DISTINCT visitor_token) AS daily
    FROM ahoy_visits
    WHERE
        (started_at + interval '28 days') > {start_time}
        AND started_at < {end_time}
    GROUP BY date
) AS dau
WHERE date BETWEEN {start_time} AND {end_time}
ORDER BY 1;
```

## Active Users

Same as [Active Visitors](#active-visitors), but counting by `user_id` instead of `visitor_token`.

```sql
SELECT
    date,
    daily AS "1 day",
    SUM(daily) OVER (order by date rows between 7 preceding and current row) AS "7 day",
    SUM(daily) OVER (order by date rows between 28 preceding and current row) AS "28 day"
FROM (
    SELECT
        date_trunc('day', started_at) date,
        COUNT(DISTINCT user_id) AS daily
    FROM ahoy_visits
    WHERE
        (started_at + interval '28 days') > {start_time}
        AND started_at < {end_time}
    GROUP BY date
) AS dau
WHERE date BETWEEN {start_time} AND {end_time}
ORDER BY 1;
```

## Pageviews

```sql
SELECT date_trunc('day', time) AS date, COUNT(*)
FROM ahoy_events
WHERE name = '$view' AND time BETWEEN {start_time} AND {end_time}
GROUP BY 1
ORDER BY 1;
```

## Bounce Rate

website bounce rate = single-page sessions / total sessions

```sql
SELECT
    date_trunc('day', started_at) AS "Date",
    ROUND(SUM(bounces)::numeric/COUNT(*), 2) AS "Bounce rate"
FROM (
    SELECT
        started_at,
        COUNT(*) AS pageviews,
        CASE WHEN count(*) = 1 THEN 1 ELSE 0 END AS bounces
    FROM ahoy_events
    JOIN ahoy_visits ON ahoy_events.visit_id = ahoy_visits.id
    WHERE name = '$view' AND started_at BETWEEN {start_time} AND {end_time}
    GROUP BY 1, ahoy_visits.id
) AS bounces
GROUP BY 1
ORDER BY 1;
```

## Session Duration

```sql
SELECT date_trunc('day', started_at), AVG(duration) AS seconds
FROM (
    SELECT started_at, MAX(e.time) - MIN(e.time) AS duration
    FROM ahoy_visits v
    JOIN ahoy_events e ON v.id = e.visit_id
    WHERE started_at BETWEEN {start_time} AND {end_time}
    GROUP BY v.id
) AS visits
GROUP BY 1
```

## Pages per session

```sql
SELECT date_trunc('day', started_at), ROUND(AVG(pageviews), 1) AS pageviews
FROM (
    SELECT v.started_at, COUNT(e.*) pageviews
    FROM ahoy_visits v
    JOIN ahoy_events e ON v.id = e.visit_id AND e.name = '$view'
    WHERE started_at BETWEEN {start_time} AND {end_time}
    GROUP BY 1
) AS pageviews_per_visit
GROUP BY 1
```

### Top Pages

```sql
SELECT split_part(properties->>'url', '?', 1) AS page, COUNT(*)::text AS views
FROM ahoy_events
WHERE name = '$view' AND time BETWEEN {start_time} AND {end_time}
GROUP BY 1
ORDER BY COUNT(*) DESC
LIMIT 20
```
