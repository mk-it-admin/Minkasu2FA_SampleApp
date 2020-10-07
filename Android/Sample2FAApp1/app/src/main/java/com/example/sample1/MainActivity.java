package com.example.sample1;

import android.os.Bundle;
import android.util.Log;

import androidx.appcompat.app.ActionBarDrawerToggle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.core.view.GravityCompat;
import androidx.drawerlayout.widget.DrawerLayout;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;

import android.view.Menu;
import android.view.MenuItem;

import com.google.android.material.navigation.NavigationView;
import com.minkasu.android.twofa.enums.Minkasu2faOperationType;
import com.minkasu.android.twofa.sdk.Minkasu2faSDK;

import java.util.List;

public class MainActivity extends AppCompatActivity implements NavigationView.OnNavigationItemSelectedListener
{
    public static final String MERCHANT_CUSTOMER_ID = "Suresh_1";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        DrawerLayout drawer = findViewById(R.id.drawer_layout);
        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(
                this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
        drawer.setDrawerListener(toggle);
        toggle.syncState();

        NavigationView navigationView = findViewById(R.id.nav_view);
        navigationView.setNavigationItemSelectedListener(this);
        hideItems();
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    public void onBackPressed() {
        DrawerLayout drawer = findViewById(R.id.drawer_layout);
        if (drawer.isDrawerOpen(GravityCompat.START)) {
            drawer.closeDrawer(GravityCompat.START);
        } else {
            super.onBackPressed();
        }
    }

    private void hideItems() {
        NavigationView navigationView = findViewById(R.id.nav_view);
        Menu nav_Menu = navigationView.getMenu();

        //Gets the list of Operations that is available according to the state of Minkasu 2FA SDK.
        List<Minkasu2faOperationType> operationTypes =  Minkasu2faSDK.getMinkasu2faOperationTypes(getApplicationContext());

        nav_Menu.findItem(R.id.nav_change_pin).setVisible(false);
        nav_Menu.findItem(R.id.nav_enabledisablefinger).setVisible(false);

        for (int i = 0; i < operationTypes.size(); i++) {
            if (operationTypes.get(i) == Minkasu2faOperationType.CHANGE_PAYPIN) {
                nav_Menu.findItem(R.id.nav_change_pin).setVisible(true);
            } else if (operationTypes.get(i) == Minkasu2faOperationType.DISABLE_FINGERPRINT) {
                MenuItem item = nav_Menu.findItem(R.id.nav_enabledisablefinger).setVisible(true);
                item.setTitle(Minkasu2faOperationType.valueOf(Minkasu2faOperationType.DISABLE_FINGERPRINT));
            } else if (operationTypes.get(i) == Minkasu2faOperationType.ENABLE_FINGERPRINT) {
                MenuItem item = nav_Menu.findItem(R.id.nav_enabledisablefinger).setVisible(true);
                item.setTitle(Minkasu2faOperationType.valueOf(Minkasu2faOperationType.ENABLE_FINGERPRINT));
            }
        }

    }

    @Override
    public boolean onNavigationItemSelected(MenuItem item) {
        // Handle navigation view item clicks here.
        int id = item.getItemId();
        Fragment fragment;
        String fragmentTag;
        if (id == R.id.nav_reset) {
            DrawerLayout drawer = findViewById(R.id.drawer_layout);
            drawer.closeDrawer(GravityCompat.START);
            popAllFragmentsInStack();
        } else if (id == R.id.nav_auth_pay) {
            fragment = getAuthPayFragment();
            fragmentTag = "PayFragment";

            DrawerLayout drawer = findViewById(R.id.drawer_layout);
            drawer.closeDrawer(GravityCompat.START);
            FragmentManager fragmentManager = getSupportFragmentManager();

            popAllFragmentsInStack();
            fragmentManager.beginTransaction().replace(R.id.content_main, fragment,fragmentTag).commit();
        } else if (id == R.id.nav_change_pin) {
            performMKSDKAction(Minkasu2faOperationType.CHANGE_PAYPIN);
            DrawerLayout drawer = findViewById(R.id.drawer_layout);
            drawer.closeDrawer(GravityCompat.START);
            popAllFragmentsInStack();
        } else if (id == R.id.nav_enabledisablefinger) {
            performMKSDKAction(Minkasu2faOperationType.ENABLE_FINGERPRINT);
            DrawerLayout drawer = findViewById(R.id.drawer_layout);
            drawer.closeDrawer(GravityCompat.START);
            popAllFragmentsInStack();
        }
        return true;
    }

    private void popAllFragmentsInStack() {
        FragmentManager fragmentManager = getSupportFragmentManager();
        int stack_size_1 = fragmentManager.getBackStackEntryCount();
        for (int i = 0; i < stack_size_1; i++) {
            fragmentManager.popBackStackImmediate();
        }
        int stack_size_2 = fragmentManager.getBackStackEntryCount();
        Log.i("MinkasuSDKActivity", "PopAllFramgents: stack size changed from " + stack_size_1
                + " to  " + stack_size_2);
    }

    private Fragment getAuthPayFragment() {
        Bundle args;
        AuthPayFragment fragment = new AuthPayFragment();
        args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    private void performMKSDKAction (Minkasu2faOperationType operationType){
        try {
            //Creating Minkasu 2FA SDK object to perform the selected menu action.
            Minkasu2faSDK minkasu2faSDKInstance = Minkasu2faSDK.create(MainActivity.this, operationType,MERCHANT_CUSTOMER_ID);
            minkasu2faSDKInstance.start();
        }
        catch(Exception e){
            Log.i("Exception",e.toString());
        }
    }
}
