# Jaffle shop definitions

How we define the terms in questions about the jaffle shop data in `climb.marts`. Use these definitions unless the question says otherwise, and state the definition you used in your answer.

If the question is ambiguous, ask, or pick one reading, say which, and give one answer.

## 1. The current period

The data ends on 2026-08-31 and isn't refreshed, so periods are anchored on the last day with data, not on today's date. That day is the reference date, and it counts as a complete day. The month, quarter or year holding it is the current one, even if the data runs to its final day.

- **This month** is the month of the reference date, **last month** is the month before it. With data ending 2026-08-31, August 2026 is this month and July 2026 is last month.
- **This quarter** is the quarter of the reference date, **last quarter** is the quarter before it.
- **This year** is the year of the reference date, **last year** is the year before it.
- "Last month", "last quarter" and "last year" always mean the period before the current one, never the latest period with data.
- A month or quarter named without a year means its latest occurrence up to the reference date. Year over year compares it with the same period a year earlier. Tell the user which year you took.
- "Last N days" and "last N months" aren't calendar periods but rolling windows: see section 2.
- Whenever an answer covers a period, say how you read it (calendar period or rolling window) and give the exact dates it covers. The user may read the period another way, and two periods in one answer can look inconsistent without it.

## 2. Rolling windows

"Last N days" and "last N months" are rolling windows: they end on the reference date, included, and count back whole days or months.

- With data ending 2026-08-31, the last 3 months are June to August 2026, while last month is July.
- Filter on whole dates, with end_date as the reference date. For N days: `ordered_at::date between end_date - (N - 1) and end_date`. For N months: `ordered_at::date > end_date - interval 'N months'`. Don't use `max(ordered_at) - interval 'N days'`: `ordered_at` is truncated to midnight in the marts, so that window takes one extra day.
- "Currently", "now" and "these days" without a period mean the last 28 days (a rolling window). Say so in the answer.

## 3. Comparing years

When the current year is partial, compare the same span in both years: January 1 to the reference date, against the same dates a year earlier. Lead with that comparison, not with full year totals. The same applies to a partial quarter or month.

## 4. Revenue

Revenue is sales before tax: `orders.subtotal`, in dollars.

- `orders.order_total` includes tax, so it isn't revenue. `orders.tax_paid` is the tax.
- The same applies to anything built on revenue: average order value, revenue by store or month, revenue growth.

## 5. New customers

A new customer is a customer whose first order falls in the period the question asks about. Without a period, new means a first order in the last 3 months (see section 2).

- Use `customers.first_ordered_at` to find a customer's first order.
- A customer stays new for that period even if they have ordered again since.

## 6. Customers across stores

To know whether customers moved between stores (a new store taking customers, customers switching stores), follow the customers, not store totals: check the customer ids of one store and see whether you can find them in other stores, and when they ordered there. Store totals can change for many reasons and don't show where customers came from.

## 7. Product popularity and demand

If a question asks about product popularity or product demand, answer in units sold.

## 8. Profit margin

Profit margin is defined as the share of a product's price left after its supply cost: (price − supply cost) / price.
