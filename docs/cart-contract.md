# Cart Contract

This contract defines the cart behavior before cart migrations and implementation begin. It is aligned with the required scenarios in `docs/audit.md`.

## Models

### Cart

- A cart has many cart items.
- A signed-in user has one cart.
- A guest cart is associated with the browser session.
- A cart may belong to a user or to a guest session, but not both.

### CartItem

- A cart item belongs to one cart and one product.
- Each product appears at most once per cart.
- A cart item stores the quantity of that product.
- Quantity must be a positive integer.
- Deleting a product removes its cart items.
- A cart item can only be changed through its current cart.

## Adding and removing products

- Adding a product that is not in the cart creates a cart item with quantity `1`.
- Adding the same product again increases its quantity by `1`.
- Removing one unit decreases its quantity by `1`.
- When the quantity reaches `0`, the cart item is removed.

## Cart total and count

- The cart count is the sum of all item quantities.
- The total is the sum of each product's current price multiplied by its quantity.
- Count and total update after every cart change.

## Guest cart and sign-in

- A guest can add products without signing in.
- The browser session stores the guest cart ID.
- When a guest signs in, the guest cart contents merge into that user's cart.
- If the user does not already have a cart, create one and merge the guest items into it.
- If the same product is in both carts, add the quantities together so the product appears once.
- Perform the merge as one transaction so a partial merge cannot be left behind.
- After a successful merge, clear the guest cart and remove its ID from the session.
- A signed-in user's cart remains associated with that account after sign-out. A later guest session or another user must not see it.

## Empty cart

- The cart page has an **Empty Cart** button.
- Choosing it asks for confirmation with the exact text **“Are you sure?”**.
- Confirming removes all cart items and redirects to the homepage.
- The user's cart remains available and can be reused after it is emptied.

## Messages

- Adding a product shows **“Added to your cart”**.
- Removing a product shows **“Removed from your cart”**.
- Each message disappears after about four seconds.

## Proposed endpoints

- `GET /cart` — show the current cart.
- `POST /cart/items` — add a product.
- `DELETE /cart/items/:id` — remove one unit of an item; delete the cart-item row when its quantity reaches zero.
- `DELETE /cart` — empty the current cart.

## Audit acceptance checks

- Add one product and confirm the cart badge shows `1`.
- Add four more products and confirm the cart contains five units and the badge shows `5`.
- Remove one unit and confirm the total updates and the badge shows `4`.
- Confirm the second user's cart is separate from the first user's cart.
- Add products as a guest, sign in, and confirm those products are in the signed-in user's cart.
- Confirm the add and remove messages appear and then disappear after about four seconds.
- Empty the cart, confirm the **“Are you sure?”** prompt, and verify the cart is cleared and the app returns to the homepage.

## Agreements

- **Agreed by:** Ltzokas,Sgraika            
- **Date:** 12/11/2026
