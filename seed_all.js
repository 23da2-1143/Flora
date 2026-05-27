const apiKey = 'AIzaSyCZexjugo3slfC_OMpCPEh1iGAwJlhpDts';
const projectId = 'flora-d6444';

// Sample customer account details
const customerEmail = 'customer@flora.com';
const customerPassword = 'floraCustomer123!';

async function authenticateCustomer() {
  console.log(`Authenticating seeder customer account: ${customerEmail}...`);
  const signInUrl = `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${apiKey}`;
  
  let res = await fetch(signInUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: customerEmail, password: customerPassword, returnSecureToken: true })
  });

  if (res.ok) {
    const data = await res.json();
    console.log("Successfully logged into existing customer account.");
    return { uid: data.localId, token: data.idToken };
  }

  // If login fails, try to sign up
  console.log("Account does not exist yet. Registering new customer account...");
  const signUpUrl = `https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${apiKey}`;
  res = await fetch(signUpUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: customerEmail, password: customerPassword, returnSecureToken: true })
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`Failed to create seeder customer account: ${res.statusText}. Response: ${errText}`);
  }

  const data = await res.json();
  console.log("Successfully registered customer account.");
  return { uid: data.localId, token: data.idToken };
}

async function seedUserProfile(uid, token) {
  console.log("Writing User Profile data to Firestore 'users' collection...");
  const url = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/users/${uid}?key=${apiKey}`;
  
  const payload = {
    fields: {
      name: { stringValue: "Aria Thorne" },
      email: { stringValue: customerEmail },
      phone: { stringValue: "+1 234 567 890" },
      address: { stringValue: "123 Elegance Lane" },
      photoUrl: { stringValue: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200" },
      createdAt: { timestampValue: new Date().toISOString() }
    }
  };

  const res = await fetch(url, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify(payload)
  });

  if (!res.ok) {
    const err = await res.text();
    throw new Error(`Failed to write user profile: ${err}`);
  }
  console.log("User Profile successfully created!");
}

async function seedUserCart(uid, token) {
  console.log("Populating User Cart data in Firestore 'carts' collection...");
  const url = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/carts/${uid}?key=${apiKey}`;

  const payload = {
    fields: {
      items: {
        arrayValue: {
          values: [
            {
              mapValue: {
                fields: {
                  product: {
                    mapValue: {
                      fields: {
                        id: { stringValue: "1" },
                        name: { stringValue: "Eleanor Chiffon Maxi Dress" },
                        price: { doubleValue: 129.99 },
                        imageUrl: { stringValue: "https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=compress&cs=tinysrgb&w=400&h=600&fit=crop" },
                        category: { stringValue: "Formal Dresses" },
                        rating: { doubleValue: 4.8 },
                        reviews: { integerValue: 124 },
                        stock: { integerValue: 10 }
                      }
                    }
                  },
                  quantity: { integerValue: 1 },
                  selectedSize: { stringValue: "S" },
                  selectedColor: { stringValue: "Pink" }
                }
              }
            },
            {
              mapValue: {
                fields: {
                  product: {
                    mapValue: {
                      fields: {
                        id: { stringValue: "2" },
                        name: { stringValue: "Stella Silk Slip Dress" },
                        price: { doubleValue: 89.50 },
                        imageUrl: { stringValue: "https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?auto=compress&cs=tinysrgb&w=400&h=600&fit=crop" },
                        category: { stringValue: "Party Dresses" },
                        rating: { doubleValue: 4.5 },
                        reviews: { integerValue: 89 },
                        stock: { integerValue: 10 }
                      }
                    }
                  },
                  quantity: { integerValue: 2 },
                  selectedSize: { stringValue: "M" },
                  selectedColor: { stringValue: "Gold" }
                }
              }
            }
          ]
        }
      },
      updatedAt: { timestampValue: new Date().toISOString() }
    }
  };

  const res = await fetch(url, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify(payload)
  });

  if (!res.ok) {
    const err = await res.text();
    throw new Error(`Failed to write cart: ${err}`);
  }
  console.log("User Cart successfully populated!");
}

async function seedUserOrders(uid, token) {
  console.log("Seeding multiple sample orders in root 'orders' collection...");
  
  const sampleOrders = [
    {
      id: "seed_order_1",
      total: 75.00,
      status: "Shipped",
      paymentStatus: "Paid",
      createdAt: new Date(Date.now() - 86400000).toISOString(), // 1 day ago
      items: [
        {
          productId: "3",
          productName: "Chloe Floral Sundress",
          imageUrl: "https://images.unsplash.com/photo-1496747611176-843222e1e57c?auto=compress&cs=tinysrgb&w=400&h=600&fit=crop",
          quantity: 1,
          price: 65.00,
          selectedSize: "S",
          selectedColor: "White/Floral"
        }
      ],
      deliveryDetails: {
        fullName: "Aria Thorne",
        phoneNumber: "+1 234 567 890",
        address: "123 Elegance Lane",
        city: "New York",
        deliveryNotes: "Leave at reception."
      }
    },
    {
      id: "seed_order_2",
      total: 319.48,
      status: "Pending",
      paymentStatus: "Pending",
      createdAt: new Date().toISOString(), // Today
      items: [
        {
          productId: "1",
          productName: "Eleanor Chiffon Maxi Dress",
          imageUrl: "https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=compress&cs=tinysrgb&w=400&h=600&fit=crop",
          quantity: 1,
          price: 129.99,
          selectedSize: "S",
          selectedColor: "Pink"
        },
        {
          productId: "2",
          productName: "Stella Silk Slip Dress",
          imageUrl: "https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?auto=compress&cs=tinysrgb&w=400&h=600&fit=crop",
          quantity: 2,
          price: 89.50,
          selectedSize: "M",
          selectedColor: "Gold"
        }
      ],
      deliveryDetails: {
        fullName: "Aria Thorne",
        phoneNumber: "+1 234 567 890",
        address: "123 Elegance Lane",
        city: "New York",
        deliveryNotes: "Ring bell upon arrival."
      }
    }
  ];

  for (const order of sampleOrders) {
    const url = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/orders/${order.id}?key=${apiKey}`;
    
    const payload = {
      fields: {
        userId: { stringValue: uid },
        totalAmount: { doubleValue: order.total },
        orderStatus: { stringValue: order.status },
        paymentStatus: { stringValue: order.paymentStatus },
        createdAt: { timestampValue: order.createdAt },
        items: {
          arrayValue: {
            values: order.items.map(item => ({
              mapValue: {
                fields: {
                  productId: { stringValue: item.productId },
                  productName: { stringValue: item.productName },
                  imageUrl: { stringValue: item.imageUrl },
                  quantity: { integerValue: item.quantity },
                  price: { doubleValue: item.price },
                  selectedSize: { stringValue: item.selectedSize },
                  selectedColor: { stringValue: item.selectedColor }
                }
              }
            }))
          }
        },
        deliveryDetails: {
          mapValue: {
            fields: {
              fullName: { stringValue: order.deliveryDetails.fullName },
              phoneNumber: { stringValue: order.deliveryDetails.phoneNumber },
              address: { stringValue: order.deliveryDetails.address },
              city: { stringValue: order.deliveryDetails.city },
              deliveryNotes: { stringValue: order.deliveryDetails.deliveryNotes }
            }
          }
        }
      }
    };

    const res = await fetch(url, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify(payload)
    });

    if (!res.ok) {
      const err = await res.text();
      throw new Error(`Failed to write order ${order.id}: ${err}`);
    }
    console.log(`Successfully seeded order: ${order.id}`);
  }
}

async function runSeeder() {
  const { uid, token } = await authenticateCustomer();
  await seedUserProfile(uid, token);
  await seedUserCart(uid, token);
  await seedUserOrders(uid, token);
  console.log("\nAll Firestore E-Commerce collections successfully seeded!");
  console.log(`\nTo test this profile in the app, log in using:`);
  console.log(`Email: ${customerEmail}`);
  console.log(`Password: ${customerPassword}`);
  process.exit(0);
}

runSeeder().catch(e => {
  console.error("Seeding failed:", e);
  process.exit(1);
});
