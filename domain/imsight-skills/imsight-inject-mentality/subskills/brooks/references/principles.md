# Brooks Constructive Principles

This catalog converts Brooks Lint's diagnostic risks into preventive reminders for writing production code and tests. It is derived from the upstream Brooks Lint risk references at `skills/_shared/decay-risks.md` and `skills/_shared/test-decay-risks.md`; the reminders are intentionally constructive rather than finding-oriented.

## Workflow

1. Load the current selected codes from Brooks state.
2. Use only the matching compact reminders from **Production Rules** and **Test Rules**.
3. Ground each selected rule in its **Representative Do / Don't comparison**, then apply its judgment note while planning, implementing, and verifying the current change.
4. Render selected reminders without diagnostic scoring or unselected content.

If the task does not map cleanly to these steps, use the native planning tool to apply the selected reminders proportionately to the code and tests in scope.

## Production Rules

| Code | Canonical name | Compact injected reminder |
| --- | --- | --- |
| `r1` | `comprehension` | Keep the concepts a reader must hold manageable with precise names, cohesive flow, and consistent abstraction levels. |
| `r2` | `change-boundary` | Put the change at the narrowest correct shared boundary; trace callers and hide decisions that should not propagate. |
| `r3` | `decision-ownership` | Give each business decision one clear source of truth; remove duplicated knowledge, not merely similar syntax. |
| `r4` | `essential-complexity` | Require every abstraction, layer, option, and dependency to justify its present cost; simplicity is not code golf. |
| `r5` | `dependency-direction` | Keep policy independent of concrete infrastructure, avoid cycles, and introduce interfaces only at real boundaries. |
| `r6` | `domain-fidelity` | Use the domain's language and keep invariants with the model that owns them; translate explicitly across bounded contexts. |

### Representative Do / Don't comparisons

These original examples synthesize the linked sources into small teaching cases. Use the comparison to recognize the design move, not as a language-specific recipe or an unconditional demand to introduce the shown abstraction.

- **`r1` — `comprehension`** ([Software Engineering at Google — Style Guides](https://abseil.io/resources/swe-book/html/ch08.html))

  **Don't:** Mix several responsibilities, abstraction levels, and nested decisions behind a vague name.

  ```python
  def process(order):
      if order.items:
          total = sum(item.price for item in order.items)
          if order.customer.active:
              mailer.send(order.customer, total)
              repository.save(order, total)
  ```

  **Do:** Make the high-level flow readable through cohesive, intention-revealing steps.

  ```python
  def submit_order(order):
      validated_order = validate_order(order)
      priced_order = price_order(validated_order)
      persist_order(priced_order)
      send_confirmation(priced_order)
  ```

- **`r2` — `change-boundary`** ([Martin Fowler — the Shotgun Surgery problem](https://martinfowler.com/articles/modularizing-react-apps.html))

  **Don't:** Repeat the same volatile decision in every consumer.

  ```python
  # checkout.py
  currency = "JPY" if country == "JP" else "USD"

  # receipt.py
  currency = "JPY" if country == "JP" else "USD"

  # analytics.py
  currency = "JPY" if country == "JP" else "USD"
  ```

  **Do:** Put the decision behind the narrowest shared boundary and let consumers ask it.

  ```python
  payment_policy = payment_policy_for(country)

  checkout.render(currency=payment_policy.currency)
  receipt.render(currency=payment_policy.currency)
  analytics.record(currency=payment_policy.currency)
  ```

- **`r3` — `decision-ownership`** ([The Pragmatic Programmer — DRY](https://books.pragprog.com/tips/))

  **Don't:** Encode one business rule independently in several paths.

  ```python
  # checkout.py
  free_shipping = order.total >= 100

  # invoice.py
  shipping_fee = 0 if order.total >= 100 else 10

  # refund.py
  included_free_shipping = original_total >= 100
  ```

  **Do:** Give the decision one authoritative owner wherever it has the same meaning.

  ```python
  class ShippingPolicy:
      def qualifies_for_free_shipping(self, order):
          return order.total >= self.free_shipping_threshold
  ```

- **`r4` — `essential-complexity`** ([Martin Fowler — YAGNI](https://martinfowler.com/bliki/Yagni.html))

  **Don't:** Build extension machinery for hypothetical requirements.

  ```python
  class StorageProvider(Protocol): ...
  class StorageProviderRegistry: ...
  class StoragePluginLoader: ...
  class StorageProviderFactory: ...

  store = StorageProviderFactory.create("file")
  ```

  **Do:** Implement today's requirement directly and extract a boundary when real variation arrives.

  ```python
  store = FileStore(root=data_directory)
  store.save(document)
  ```

- **`r5` — `dependency-direction`** ([Microsoft — Clean architecture](https://learn.microsoft.com/en-us/dotnet/architecture/modern-web-apps-azure/common-web-application-architectures))

  **Don't:** Make core policy construct and depend on an infrastructure detail.

  ```python
  from infrastructure.postgres import PostgresOrderRepository

  class OrderService:
      def __init__(self):
          self.orders = PostgresOrderRepository()
  ```

  **Do:** Define the port with the core, implement it outside, and inject the adapter at composition.

  ```python
  class OrderRepository(Protocol):
      def save(self, order): ...

  class OrderService:
      def __init__(self, orders: OrderRepository):
          self.orders = orders

  order_service = OrderService(PostgresOrderRepository(database))
  ```

- **`r6` — `domain-fidelity`** ([Microsoft — Designing a DDD domain model](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/microservice-domain-model))

  **Don't:** Let an application service duplicate an entity's rules and mutate its state.

  ```python
  def cancel_order(order, requested_at):
      if order.status == "paid" and requested_at < order.ship_by:
          order.status = "cancelled"
  ```

  **Do:** Express the operation in domain language and let the model protect its invariant.

  ```python
  class Order:
      def cancel(self, requested_at):
          if self.status != "paid" or requested_at >= self.ship_by:
              raise OrderCannotBeCancelled()
          self.status = "cancelled"
  ```

### Judgment notes

- R1: Function length, nesting, parameter count, and fan-out are review signals. Clear linear code or a deep module may be healthy despite a threshold.
- R2: A composition root may wire concrete dependencies. Coordinated changes inside one bounded context are not automatically propagation debt.
- R3: Similar code in separate bounded contexts may represent different decisions. Local repetition can be clearer than false sharing.
- R4: Thin wrappers are justified when they absorb vendor churn or isolate instability. A closed protocol switch is not automatically missing polymorphism.
- R5: Adapters may depend on both domain and infrastructure to translate between them. High orchestration fan-out can be intentional.
- R6: DTOs, persistence records, and API payloads may be data-only. Simple CRUD may not need a rich domain model.

## Test Rules

| Code | Canonical name | Compact injected reminder |
| --- | --- | --- |
| `t1` | `test-intent` | Make the scenario, action, and expected outcome obvious in the test name and visible setup. |
| `t2` | `test-resilience` | Assert observable behavior through stable interfaces and control nondeterminism so refactoring does not break valid tests. |
| `t3` | `test-knowledge` | Give shared test knowledge one owner while keeping scenario-specific data and intent visible. |
| `t4` | `mock-boundaries` | Mock genuine external, slow, or nondeterministic boundaries; prefer behavior evidence over internal call choreography. |
| `t5` | `risk-coverage` | Cover material success, failure, boundary, side-effect, and regression risks instead of treating line coverage as proof. |
| `t6` | `test-architecture` | Match test levels, seams, fixtures, and feedback speed to the system's architecture and risk profile. |

### Representative Do / Don't comparisons

These examples are likewise illustrative. Preserve the observable contract and risk being tested when adapting them to the project's framework and test architecture.

- **`t1` — `test-intent`** ([Google Testing Blog — Writing Descriptive Test Names](https://testing.googleblog.com/2014/10/testing-on-toilet-writing-descriptive.html))

  **Don't:** Use a vague name and hide the decisive scenario facts in a general fixture.

  ```python
  def test_login(account):
      login(account, "wrong")
      login(account, "wrong")
      login(account, "wrong")
      assert account.locked
  ```

  **Do:** State the scenario and outcome in the name and keep the decisive setup visible.

  ```python
  def test_third_invalid_password_locks_account(active_account):
      login(active_account, "wrong")
      login(active_account, "wrong")
      login(active_account, "wrong")

      assert active_account.is_locked()
  ```

- **`t2` — `test-resilience`** ([Software Engineering at Google — Unit Testing](https://abseil.io/resources/swe-book/html/ch12.html))

  **Don't:** Couple the test to private state and internal call choreography.

  ```python
  service.find_user("ada")

  assert service._cache["ada"] == ada
  repository.get.assert_called_once_with("ada")
  cache.put.assert_called_once_with("ada", ada)
  ```

  **Do:** Assert the observable result promised by the public interface.

  ```python
  found_user = service.find_user("ada")

  assert found_user == ada
  ```

- **`t3` — `test-knowledge`** ([Google Testing Blog — Cleanly Create Test Data](https://testing.googleblog.com/2018/02/testing-on-toilet-cleanly-create-test.html))

  **Don't:** Repeat a large valid object while burying the one scenario-specific value.

  ```python
  order = Order(
      customer=active_customer,
      items=[book],
      address=valid_address,
      payment_method=expired_card,
      currency="USD",
  )
  ```

  **Do:** Centralize valid defaults and make the relevant exception explicit in the test.

  ```python
  order = an_order().with_payment_method(expired_card).build()

  result = checkout(order)

  assert result.error == "payment method expired"
  ```

- **`t4` — `mock-boundaries`** ([Google Testing Blog — Don't Overuse Mocks](https://testing.googleblog.com/2013/05/testing-on-toilet-dont-overuse-mocks.html))

  **Don't:** Mock every collaborator and make implementation order the primary assertion.

  ```python
  service = RenewalService(repo_mock, clock_mock, logger_mock, notifier_mock)

  service.renew(subscription)

  manager.assert_has_calls([repo_mock.save, logger_mock.info, notifier_mock.send])
  ```

  **Do:** Use deterministic collaborators, assert behavior, and mock only the true external boundary.

  ```python
  repository = InMemorySubscriptions([subscription])
  service = RenewalService(repository, FixedClock(today), notifier_mock)

  service.renew(subscription.id)

  assert repository.get(subscription.id).expires_on == next_year
  notifier_mock.send.assert_called_once_with(subscription.customer)
  ```

- **`t5` — `risk-coverage`** ([Google Testing Blog — Understanding Your Coverage Data](https://testing.googleblog.com/2008/03/tott-understanding-your-coverage-data.html))

  **Don't:** Treat one line-covering happy path as proof that withdrawal behavior is covered.

  ```python
  def test_withdrawal():
      account = Account(balance=100)
      account.withdraw(20)
      assert account.balance == 80
  ```

  **Do:** Cover material boundaries and verify the side effects the feature can get wrong.

  ```python
  def test_exact_balance_withdrawal_empties_account():
      account = Account(balance=100)
      account.withdraw(100)
      assert account.balance == 0

  def test_insufficient_funds_preserves_balance():
      account = Account(balance=100)
      with raises(InsufficientFunds):
          account.withdraw(101)
      assert account.balance == 100

  def test_successful_withdrawal_persists_and_emits_event():
      service.withdraw(account_id, 20)
      assert repository.get(account_id).balance == 80
      assert events.published == [MoneyWithdrawn(account_id, 20)]
  ```

- **`t6` — `test-architecture`** ([Google Testing Blog — Just Say No to More End-to-End Tests](https://testing.googleblog.com/2015/04/just-say-no-to-more-end-to-end-tests.html))

  **Don't:** Exercise pure pricing logic only through a slow, broad browser journey.

  ```python
  def test_discounted_checkout_in_browser(browser, live_payment_gateway):
      browser.add_product("book")
      browser.apply_coupon("READ20")
      browser.pay(live_payment_gateway)
      assert browser.receipt_total() == Money("8.00")
  ```

  **Do:** Put each risk at the smallest useful level and retain one critical journey check.

  ```python
  def test_read20_reduces_book_price_by_twenty_percent():           # unit
      assert price(book, coupon="READ20") == Money("8.00")

  def test_payment_adapter_submits_discounted_total():              # integration
      payment_adapter.charge(order_total=Money("8.00"))
      assert gateway.received_amount == Money("8.00")

  def test_customer_can_complete_discounted_purchase(browser):     # end-to-end
      browser.buy("book", coupon="READ20")
      assert browser.receipt_total() == Money("8.00")
  ```

### Judgment notes

- T1: Several assertions are fine when they tell one coherent behavioral story. Shared setup is fine when it is relevant and visible.
- T2: An emitted command or external interaction can be observable behavior. Fakes and spies are acceptable when assertions remain behavioral.
- T3: The same scenario may appear at several levels when each protects a distinct risk. Small local setup duplication can improve clarity.
- T4: Interaction assertions are appropriate when the interaction itself is the contract. Realistic fakes are not mock abuse by default.
- T5: Coverage metrics are useful evidence when paired with boundary, branch, and change-path reasoning.
- T6: Test-pyramid ratios and runtime thresholds are heuristics. Platform constraints and product risk can justify a different shape.

## Applicability

- Apply production rules to new or modified production code, architecture, APIs, and dependency decisions.
- Apply test rules when adding, changing, selecting, or reviewing tests for the requested implementation.
- A selected test rule may influence production seams only when doing so serves a real testability and architecture boundary.
- If the task is non-coding, Brooks is not applicable and renders no injection.

## Provenance

The diagnostic taxonomy and exceptions originate from [Brooks Lint](https://github.com/hyhmrright/brooks-lint). This mentality does not copy its audit workflow, severity system, health score, or Iron Law because its purpose is preventive authorship rather than post-hoc diagnosis.

## Guardrails

- DO NOT turn a compact reminder into an unconditional numeric threshold.
- DO NOT inject rules that are absent from the selected state.
- DO NOT reproduce Brooks Lint report language when guiding implementation.
