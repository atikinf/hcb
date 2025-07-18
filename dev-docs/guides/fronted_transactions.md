# What does it mean to front a transaction on HCB?

Money takes time to move and HCB only imports transactions from our bank account once a day.  To make money movement feel instant, we do a lot of transaction fronting.

**What is a [`CanonicalPendingTransaction`](https://github.com/hackclub/hcb/blob/main/app/models/canonical_pending_transaction.rb)?**

We create a [`CanonicalPendingTransaction`](https://github.com/hackclub/hcb/blob/main/app/models/canonical_pending_transaction.rb) when we expect a transaction to happen but it hasn’t appeared on our bank statement yet (all transactions on our bank statements are stored as [`CanonicalTransaction`](https://github.com/hackclub/hcb/blob/main/app/models/canonical_transaction.rb)s).

[`CanonicalPendingTransaction`](https://github.com/hackclub/hcb/blob/main/app/models/canonical_pending_transaction.rb)s are temporary - they should either settle as a [`CanonicalTransaction`](https://github.com/hackclub/hcb/blob/main/app/models/canonical_transaction.rb) or be declined (when we no longer expect the transaction to happen).

By default, negative [`CanonicalPendingTransaction`](https://github.com/hackclub/hcb/blob/main/app/models/canonical_pending_transaction.rb)s affect an organisation’s balance but positive [`CanonicalPendingTransaction`](https://github.com/hackclub/hcb/blob/main/app/models/canonical_pending_transaction.rb)s don’t. That’s a liability thing, if we give an organisation access to funds that never end up hitting our account, we have to cover the difference if they choose to spend it.

**So what does it mean to front a transaction?**

By fronting a positive [`CanonicalPendingTransaction`](https://github.com/hackclub/hcb/blob/main/app/models/canonical_pending_transaction.rb), we allow that transaction to change an organisation’s balance. For example, the moment an organisation receives a donation, we create a [`CanonicalPendingTransaction`](https://github.com/hackclub/hcb/blob/main/app/models/canonical_pending_transaction.rb) and set it’s `fronted` to `true`.

**When should we front transactions?**

When a transaction settling is guaranteed. The best example of this is book transfers on Column. In a couple of pieces of documentation, I’ve described how we use book transfers for disbursements, fees, reimbursements and other features. Book transfers, if they don’t error when created on Column, are guaranteed to show up our bank statement.

By fronting these, you can get people their money faster. This is how we cut reimbursements’ time-to-bank down to a couple of hours from a couple of days:

Disbursements coming from organisations on the "[Hack Club affiliated project](https://github.com/hackclub/hcb/blob/main/app/models/event/plan/hack_club_affiliate.rb)" plan or "[HCB internal organization](https://github.com/hackclub/hcb/blob/main/app/models/event/plan/internal.rb)" plan are always fronted. This is determined by a feature on the [`Event::Plan`](https://github.com/hackclub/hcb/blob/main/app/models/event/plan.rb).

**When should we avoid fronting transactions?**

Sometimes we know a transaction will likely hit our accounts but it isn’t guaranteed. In these cases we should still make a [`CanonicalPendingTransaction`](https://github.com/hackclub/hcb/blob/main/app/models/canonical_pending_transaction.rb) but not front it. For example, check deposits, because they can bounce. 

If needs be, you can always manually front transactions:

```ruby
CanonicalPendingTransaction.find(XX).update(fronted: true)
```

**⚠️ Never leave a fronted [`CanonicalPendingTransaction`](https://github.com/hackclub/hcb/blob/main/app/models/canonical_pending_transaction.rb) unsettled for too long**

If the transaction doesn’t happen, we should decline it. And don't forget, setting a [`CanonicalTransaction`](https://github.com/hackclub/hcb/blob/main/app/models/canonical_transaction.rb)’s HCB code isn’t the same as settling it.

\- [@sampoder](https://github.com/sampoder)
