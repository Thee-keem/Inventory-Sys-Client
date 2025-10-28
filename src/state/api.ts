import { createApi, fakeBaseQuery } from "@reduxjs/toolkit/query/react";
import { supabase } from "@/lib/supabase";

export interface Product {
  productId: string;
  name: string;
  price: number;
  rating?: number;
  stockQuantity: number;
}

export interface NewProduct {
  name: string;
  price: number;
  rating?: number;
  stockQuantity: number;
}

export interface SalesSummary {
  salesSummaryId: string;
  totalValue: number;
  changePercentage?: number;
  date: string;
}

export interface PurchaseSummary {
  purchaseSummaryId: string;
  totalPurchased: number;
  changePercentage?: number;
  date: string;
}

export interface ExpenseSummary {
  expenseSummarId: string;
  totalExpenses: number;
  date: string;
}

export interface ExpenseByCategorySummary {
  expenseByCategorySummaryId: string;
  category: string;
  amount: string;
  date: string;
}

export interface DashboardMetrics {
  popularProducts: Product[];
  salesSummary: SalesSummary[];
  purchaseSummary: PurchaseSummary[];
  expenseSummary: ExpenseSummary[];
  expenseByCategorySummary: ExpenseByCategorySummary[];
}

export interface User {
  userId: string;
  name: string;
  email: string;
}

export const api = createApi({
  baseQuery: fakeBaseQuery(),
  reducerPath: "api",
  tagTypes: ["DashboardMetrics", "Products", "Users", "Expenses"],
  endpoints: (build) => ({
    getDashboardMetrics: build.query<DashboardMetrics, void>({
      async queryFn() {
        try {
          const [products, salesSummary, purchaseSummary, expenseSummary, expenseByCategory] = await Promise.all([
            supabase.from("products").select("*").order("stock_quantity", { ascending: false }).limit(5),
            supabase.from("sales_summary").select("*").order("date", { ascending: true }),
            supabase.from("purchase_summary").select("*").order("date", { ascending: true }),
            supabase.from("expense_summary").select("*").order("date", { ascending: true }),
            supabase.from("expense_by_category").select("*").order("amount", { ascending: false }),
          ]);

          if (products.error) throw products.error;
          if (salesSummary.error) throw salesSummary.error;
          if (purchaseSummary.error) throw purchaseSummary.error;
          if (expenseSummary.error) throw expenseSummary.error;
          if (expenseByCategory.error) throw expenseByCategory.error;

          return {
            data: {
              popularProducts: products.data.map((p: any) => ({
                productId: p.product_id,
                name: p.name,
                price: p.price,
                rating: p.rating,
                stockQuantity: p.stock_quantity,
              })),
              salesSummary: salesSummary.data.map((s: any) => ({
                salesSummaryId: s.sales_summary_id,
                totalValue: s.total_value,
                changePercentage: s.change_percentage,
                date: s.date,
              })),
              purchaseSummary: purchaseSummary.data.map((p: any) => ({
                purchaseSummaryId: p.purchase_summary_id,
                totalPurchased: p.total_purchased,
                changePercentage: p.change_percentage,
                date: p.date,
              })),
              expenseSummary: expenseSummary.data.map((e: any) => ({
                expenseSummarId: e.expense_summary_id,
                totalExpenses: e.total_expenses,
                date: e.date,
              })),
              expenseByCategorySummary: expenseByCategory.data.map((e: any) => ({
                expenseByCategorySummaryId: e.expense_by_category_id,
                category: e.category,
                amount: e.amount.toString(),
                date: e.date,
              })),
            },
          };
        } catch (error: any) {
          return { error: { status: 500, data: error.message } };
        }
      },
      providesTags: ["DashboardMetrics"],
    }),
    getProducts: build.query<Product[], string | void>({
      async queryFn(search) {
        try {
          let query = supabase.from("products").select("*");

          if (search) {
            query = query.ilike("name", `%${search}%`);
          }

          const { data, error } = await query;

          if (error) throw error;

          return {
            data: data.map((p: any) => ({
              productId: p.product_id,
              name: p.name,
              price: p.price,
              rating: p.rating,
              stockQuantity: p.stock_quantity,
            })),
          };
        } catch (error: any) {
          return { error: { status: 500, data: error.message } };
        }
      },
      providesTags: ["Products"],
    }),
    createProduct: build.mutation<Product, NewProduct>({
      async queryFn(newProduct) {
        try {
          const { data, error } = await supabase
            .from("products")
            .insert([
              {
                name: newProduct.name,
                price: newProduct.price,
                rating: newProduct.rating,
                stock_quantity: newProduct.stockQuantity,
              },
            ])
            .select()
            .single();

          if (error) throw error;

          return {
            data: {
              productId: data.product_id,
              name: data.name,
              price: data.price,
              rating: data.rating,
              stockQuantity: data.stock_quantity,
            },
          };
        } catch (error: any) {
          return { error: { status: 500, data: error.message } };
        }
      },
      invalidatesTags: ["Products", "DashboardMetrics"],
    }),
    getUsers: build.query<User[], void>({
      async queryFn() {
        try {
          const { data, error } = await supabase.from("users").select("*");

          if (error) throw error;

          return {
            data: data.map((u: any) => ({
              userId: u.user_id,
              name: u.name,
              email: u.email,
            })),
          };
        } catch (error: any) {
          return { error: { status: 500, data: error.message } };
        }
      },
      providesTags: ["Users"],
    }),
    getExpensesByCategory: build.query<ExpenseByCategorySummary[], void>({
      async queryFn() {
        try {
          const { data, error } = await supabase
            .from("expense_by_category")
            .select("*")
            .order("amount", { ascending: false });

          if (error) throw error;

          return {
            data: data.map((e: any) => ({
              expenseByCategorySummaryId: e.expense_by_category_id,
              category: e.category,
              amount: e.amount.toString(),
              date: e.date,
            })),
          };
        } catch (error: any) {
          return { error: { status: 500, data: error.message } };
        }
      },
      providesTags: ["Expenses"],
    }),
  }),
});

export const {
  useGetDashboardMetricsQuery,
  useGetProductsQuery,
  useCreateProductMutation,
  useGetUsersQuery,
  useGetExpensesByCategoryQuery,
} = api;
