# Trace LIA00006 Source - Debug Guide

## 🎯 **The Mystery**

The dashboard is showing a child with `liaId: "LIA00006"` that **doesn't exist** in the database. We need to trace where this data is coming from.

## 🔍 **Data Flow Analysis**

### **Step 1: Dashboard Loading**
```
DashboardScreen._fetchChildren() 
  ↓
DashboardService.getChildrenForUser()
  ↓
Multiple API endpoints tried:
  1. /api/sponsors?filters[email][$eq]=user@email.com&populate[children][populate]=images
  2. /api/sponsors?filters[email][$eq]=user@email.com&populate=children  
  3. /api/sponsors?filters[email][$eq]=user@email.com
  4. Fallback: /api/children?filters[sponsor][email][$eq]=user@email.com&populate=images
```

### **Step 2: Child Detail Service**
```
ChildDetailService.getChildDetail()
  ↓
/api/children?populate[images]=true&populate[sponsor]=true&pagination[pageSize]=100
  ↓
Returns: LIA00022 (and many others, but NO LIA00006)
```

## 🛠️ **Enhanced Debugging Added**

I've added comprehensive debugging to trace the source:

### **1. Dashboard Service Debugging**
```
[DashboardService] Trying sponsors URL: [URL]
[DashboardService] Full sponsors response: [FULL_RESPONSE]
[DashboardService] Fallback children response: [FULL_RESPONSE]
```

### **2. Dashboard Screen Debugging**
```
🔍 [Dashboard] Loading child: id=[ID], liaId=[LIA_ID], documentId=[DOC_ID], name=[NAME]
```

## 🧪 **How to Trace the Source**

### **Step 1: Run the App and Check Logs**

Look for these specific log patterns:

**Dashboard Service:**
```
[DashboardService] Trying sponsors URL: [URL]
[DashboardService] Full sponsors response: [RESPONSE]
```

**Dashboard Screen:**
```
🔍 [Dashboard] Loading child: id=[ID], liaId=LIA00006, documentId=[DOC_ID], name=[NAME]
```

### **Step 2: Identify the Source**

**If you see:**
- Dashboard Service returns `LIA00006` in the response
- But ChildDetailService only finds `LIA00022`

**This indicates:**
- **Different API endpoints** returning different data
- **Stale data** in one endpoint but not another
- **Data inconsistency** in Strapi

### **Step 3: Check Which Endpoint is Used**

The logs will show which endpoint successfully returns data:

**Option 1: Sponsors endpoint**
```
[DashboardService] Trying sponsors URL: /api/sponsors?filters[email][$eq]=user@email.com&populate=children
[DashboardService] Full sponsors response: {data: [{children: {data: [{liaId: LIA00006}]}}]}
```

**Option 2: Fallback children endpoint**
```
[DashboardService] Fallback children URL: /api/children?filters[sponsor][email][$eq]=user@email.com&populate=images
[DashboardService] Fallback children response: {data: [{liaId: LIA00006}]}
```

## 🔍 **Possible Sources of LIA00006**

### **Source 1: Sponsors Endpoint**
- **URL**: `/api/sponsors?filters[email][$eq]=user@email.com&populate=children`
- **Issue**: Sponsor record has stale child data
- **Fix**: Update sponsor record or clear cache

### **Source 2: Children Endpoint with Sponsor Filter**
- **URL**: `/api/children?filters[sponsor][email][$eq]=user@email.com&populate=images`
- **Issue**: Child record exists but has wrong sponsor relationship
- **Fix**: Check child-sponsor relationships in Strapi

### **Source 3: Cached Data**
- **Issue**: Strapi is returning cached data
- **Fix**: Clear Strapi cache or restart server

### **Source 4: Data Inconsistency**
- **Issue**: Child exists in one table but not another
- **Fix**: Check database consistency

## 🎯 **What to Look For**

When you run the app, look for:

1. **Which endpoint** returns `LIA00006`
2. **Full response data** from that endpoint
3. **Compare** with ChildDetailService response
4. **Check** if the data is stale or inconsistent

## 🔧 **Immediate Actions**

1. **Run the app** and check the new debug logs
2. **Identify which endpoint** returns `LIA00006`
3. **Check Strapi admin panel** for that specific child
4. **Verify sponsor-child relationships** are correct
5. **Clear any caches** if needed

## 📋 **Expected Debug Output**

You should see something like:
```
[DashboardService] Trying sponsors URL: /api/sponsors?filters[email][$eq]=user@email.com&populate=children
[DashboardService] Full sponsors response: {data: [{id: 123, attributes: {children: {data: [{id: 1098, attributes: {liaId: LIA00006}}]}}}]}
🔍 [Dashboard] Loading child: id=1098, liaId=LIA00006, documentId=zuj4j880luyuda89872nbhgb, name=Kebedech Kafto Kana
```

This will show exactly where `LIA00006` is coming from! 🎯
