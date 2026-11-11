# Shop: two-person agile delivery plan

## Product goal

Deliver a responsive Rails marketplace where visitors can browse listings, users can register and manage only their own listings, and guest or signed-in shoppers can maintain a persistent cart with accurate quantities and totals.

## What the repository already contains

- Rails 6.1 / Ruby 3.0 application with Devise, Bulma, CarrierWave, and product CRUD scaffolding.
- `User has_many :products` and `Product belongs_to :user` associations.
- Product listing, detail, create, and edit views, plus image upload versions.
- A flash notification auto-hide script (currently not connected to the Webpacker entrypoint).
- No cart tables, models, controllers, routes, views, or tests.

## Definition of done

Every story is complete only when:

- the happy path and authorization/error paths work;
- server-side authorization protects actions even if a user enters a URL manually;
- the feature is responsive at 375 px, 768 px, and desktop widths;
- forms, buttons, focus states, labels, and status messages are keyboard and screen-reader usable;
- automated tests cover the story and the full suite passes;
- migrations run from a clean database and seeds load successfully;
- no secrets, generated uploads, or local database files are committed.

## Sprint 0 — shared kickoff (half day)

| ID | Owner | Points | To do | Acceptance criteria |
|---|---|---:|---|---|
| S0-1 | Person 1 | 2 | Establish a clean baseline: install dependencies, create/migrate/seed the test and development databases, and record boot issues. | The app boots locally; a clean database can be created and seeded. |
| S0-2 | Person 2 | 2 | Add the test skeleton and convert `docs/audit.md` into a manual smoke-test checklist. | One command runs model, request, and system tests; audit scenarios are trackable. |
| S0-3 | Both | — | Agree on the cart contract: `Cart` has many `CartItem`s, one cart per signed-in user, quantity per product, guest cart stored by session ID, and guest items merge on sign-in. | Model names, endpoints, merge rules, and empty-cart behavior are written down before migrations are created. |

## Sprint 1 — secure marketplace foundation

### Person 1 — identity, listings, and authorization (16 points)

- [ ] **P1-1 — Complete Devise registration parameters (2)**  
  Implement `sign_up_params` and `account_update_params` in `app/controllers/registrations_controller.rb` for the exact fields in the brief. Test sign-up and account update, including the current-password requirement.

- [ ] **P1-2 — Repair product data integrity (3)**  
  Add a foreign key and index for `products.user_id`, decide how legacy ownerless rows are handled, make ownership required, increase price precision so seeded car prices are valid, and validate that price is numeric and non-negative. Remove or replace the currently undefined `not_referenced_by_any_line_item` callback so deletion cannot crash.

- [ ] **P1-3 — Enforce listing ownership on the server (5)**  
  Scope edit, update, and destroy to the signed-in user's products (or use an explicit owner check), implement `destroy`, return a safe redirect plus alert for unauthorized access, and preserve public index/show access. Hiding buttons is not sufficient authorization.

- [ ] **P1-4 — Show seller identity safely (2)**  
  Complete `product_author(product)` and use it on listing cards and product details. Handle missing/legacy owners without raising an exception.

- [ ] **P1-5 — Test the marketplace slice (4)**  
  Cover registration, creating a listing, seller display, owner edit/delete, non-owner denial, guest denial, invalid product input, and successful image upload.

### Person 2 — cart domain and endpoints (16 points)

- [ ] **P2-1 — Create cart persistence (5)**  
  Add `Cart` and `CartItem` models/migrations. Include optional cart ownership by user, product reference, integer quantity with a positive default, timestamps, foreign keys, indexes, and a uniqueness constraint on `[cart_id, product_id]`. Use `dependent: :destroy` deliberately.

- [ ] **P2-2 — Implement cart calculations (3)**  
  Add model methods for total quantity and money total using decimal arithmetic. Adding an existing product increments quantity; decrementing removes the row at zero. Define behavior when a product is deleted (recommended: cart items are removed with it).

- [ ] **P2-3 — Implement cart routes and controllers (5)**  
  Add endpoints to show the cart, add a product, decrement/remove one item, and empty the cart. Use POST/PATCH/DELETE appropriately, protect against invalid product IDs, set the exact success messages `Added to your cart` and `Removed from your cart`, and redirect empty-cart completion to home.

- [ ] **P2-4 — Test the cart domain and endpoints (3)**  
  Cover first add, repeated add, decrement, final removal, empty cart, total recalculation, invalid IDs, and product deletion behavior.

## Sprint 2 — persistent cart and polished experience

### Person 1 — marketplace UI and cart visual system (12 points)

- [ ] **P1-6 — Standardize the application shell (3)**  
  Fix the duplicate `<body>` element and choose one valid JavaScript pipeline. Ensure Rails UJS and Turbolinks load so method links, confirmation prompts, the mobile menu, and flash dismissal actually work.

- [ ] **P1-7 — Redesign browse and product pages (5)**  
  Create consistent responsive cards, image aspect ratios/fallbacks, readable price and seller hierarchy, owner-only action menus, robust long-title behavior, and useful empty states. Preserve Bulma unless the team explicitly agrees to replace it.

- [ ] **P1-8 — Design the cart interface (3)**  
  Pair to Person 2's endpoint contract and style the cart page, quantity controls, item totals, order total, empty state, destructive-action confirmation, and responsive layout. Make status changes accessible via an appropriate live region.

- [ ] **P1-9 — Polish forms and content (1)**  
  Fix malformed text such as `Choose a fileβ€¦`, improve validation/error presentation, and make sign-in, registration, account, and listing forms visually consistent.

### Person 2 — cart identity, UI behavior, and system tests (12 points)

- [ ] **P2-5 — Implement `CurrentCart` concern (5)**  
  Create `app/models/concerns/current_cart.rb`, include it where required, restore a guest cart from the session, keep each user's cart separate, and merge guest quantities into the authenticated user's cart on sign-in. Perform the merge in a transaction and prevent duplicate cart items.

- [ ] **P2-6 — Wire cart UI behavior (3)**  
  Add the cart icon/link and live quantity badge to the global navigation, add-to-cart actions on listing and detail pages, remove/decrement controls, and an `Empty Cart` confirmation. Ensure zero, one, and many item labels are correct.

- [ ] **P2-7 — Complete feedback behavior (1)**  
  Render add/remove notices consistently, auto-dismiss them after roughly four seconds without breaking screen readers, and preserve server-rendered feedback when JavaScript is unavailable.

- [ ] **P2-8 — Add end-to-end cart tests (3)**  
  Cover guest add then login merge, separation between two user carts, badge updates from 0 → 1 → 5 → 4, total updates, individual removal, empty-cart confirmation, flash messages, and home redirect.

## Final integration — both people (half day)

- [ ] Run the complete automated suite from a clean database.
- [ ] Run every scenario in `docs/audit.md` using two users plus a guest session.
- [ ] Check Chrome/Edge at mobile, tablet, and desktop widths.
- [ ] Check keyboard-only navigation, visible focus, form labels, alt text, color contrast, and flash announcements.
- [ ] Verify registration, login/logout, image upload, authorization, cart merge, cart separation, totals, deletion, and confirmations.
- [ ] Update `README.md` with supported Ruby/Rails versions, setup, database, seed account, test, and run commands.

## Work split and merge boundaries

| Person 1 primarily owns | Person 2 primarily owns |
|---|---|
| Registration controller; product model/controller/helper/views; shared layout structure; marketplace and cart SCSS; auth/product tests | Cart/cart-item migrations and models; `CurrentCart`; cart controllers/routes/views; badge/action behavior; cart tests |

Coordinate before editing `app/models/user.rb`, `app/models/product.rb`, `app/views/layouts/application.html.erb`, `config/routes.rb`, or shared JavaScript. Merge Sprint 1 data-model work before wiring Sprint 2 UI. Keep commits story-sized and include the story ID in each commit or pull request title.

## Known repository risks to resolve early

1. `Product` registers `before_destroy :not_referenced_by_any_line_item`, but that method and a line-item model do not exist; product deletion will fail.
2. Product price is `decimal(5,2)`, while seeds contain values such as 15,000 and 160,000; the migration needs greater precision before a clean seed can be trusted.
3. The layout uses `javascript_pack_tag`, but JavaScript is under `app/assets/javascript` and the Webpacker imports are commented out. Delete links, confirmation dialogs, Turbolinks events, and notification dismissal need a consistent pipeline.
4. UI-only owner controls are insecure. Authorization must be enforced in the controller and tested with direct requests.
5. There is no automated test directory in the current repository, so regressions are currently invisible.
6. The schema version is newer than the migrations present in the repository. Reconcile migration history and confirm that a clean `db:drop db:create db:migrate db:seed` reproduces the checked-in schema.

## Optional backlog (only after the core audit passes)

- [ ] Product categories and category filtering/search.
- [ ] Add-to-cart without opening a listing (already included in the core UX plan because it is low effort).
- [ ] Saved items/wishlist.
- [ ] Checkout/payment using a hosted provider; never store raw card data.
- [ ] Pagination, sorting, and product search.
- [ ] Admin moderation and listing status workflow.

